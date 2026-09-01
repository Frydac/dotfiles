import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
	buildExecutionPrompt,
	clearPlan,
	extractPlanSteps,
	nextPendingStep,
	parseSavedState,
	renderPlanSteps,
	replacePlan,
	type PlanStep,
	type SavedState,
	type WorkflowMode,
} from "./workflow-modes-v2-utils.ts";

/**
 * Workflow modes extension.
 *
 * V2 persistence and status keys remain stable so existing sessions retain
 * their saved workflow state.
 */

const SAFE_TOOLS = ["read", "grep", "find", "ls"];
const STANDARD_EXECUTE_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];

function assistantText(message: unknown): string {
	if (!message || typeof message !== "object") return "";
	const candidate = message as { role?: string; content?: unknown };
	if (candidate.role !== "assistant" || !Array.isArray(candidate.content)) return "";

	return candidate.content
		.filter((part): part is { type: "text"; text: string } => {
			return Boolean(
				part &&
					typeof part === "object" &&
					(part as { type?: string }).type === "text" &&
					typeof (part as { text?: unknown }).text === "string",
			);
		})
		.map((part) => part.text)
		.join("\n");
}

export default function workflowModes(pi: ExtensionAPI): void {
	let mode: WorkflowMode = "read";
	let baselineTools: string[] = [];
	let planSteps: PlanStep[] = [];
	let nextStep = 0;
	let completedSteps = new Set<number>();
	let lastExecutedStep: number | undefined;
	let oneStepExecution = false;
	let executingStep: number | undefined;

	function available(names: string[]): string[] {
		const all = new Set(pi.getAllTools().map((tool) => tool.name));
		return [...new Set(names)].filter((name) => all.has(name));
	}

	function executeTools(): string[] {
		return available([...baselineTools, ...STANDARD_EXECUTE_TOOLS]);
	}

	function persist(): void {
		pi.appendEntry<SavedState>("workflow-modes-v2", {
			mode,
			planSteps,
			nextStep,
			completedSteps: [...completedSteps].sort((a, b) => a - b),
			lastExecutedStep,
			baselineTools,
		});
	}

	function updateStatus(ctx: ExtensionContext): void {
		let label: string;
		if (mode === "read") label = "🔒 read";
		else if (mode === "plan") label = "📋 plan";
		else label = "⚡ execute";

		if (planSteps.length > 0) {
			const shownStep = Math.min(nextStep + 1, planSteps.length);
			label += ` · ${shownStep}/${planSteps.length}`;
		}

		const color = mode === "execute" ? "warning" : mode === "plan" ? "accent" : "success";
		ctx.ui.setStatus("workflow-mode-v2", ctx.ui.theme.fg(color, label));
	}

	function applyMode(
		newMode: WorkflowMode,
		ctx: ExtensionContext,
		options: { notify?: boolean; save?: boolean } = {},
	): void {
		mode = newMode;
		pi.setActiveTools(newMode === "execute" ? executeTools() : available(SAFE_TOOLS));
		updateStatus(ctx);

		if (options.notify !== false) {
			const detail =
				newMode === "execute"
					? "File editing and shell access are enabled."
					: newMode === "plan"
						? "Read-only tools are enabled; shell and file changes are disabled."
						: "Read-only tools are enabled; shell and file changes are disabled.";
			ctx.ui.notify(`${newMode.toUpperCase()} mode. ${detail}`, newMode === "execute" ? "warning" : "info");
		}

		if (options.save !== false) persist();
	}

	async function chooseMode(ctx: ExtensionContext): Promise<void> {
		const choice = await ctx.ui.select("Workflow mode", [
			"read — inspect and ask questions safely",
			"plan — investigate and produce a plan",
			"execute — unrestricted implementation",
		]);
		if (!choice) return;
		applyMode(choice.split(" ")[0] as WorkflowMode, ctx);
	}

	function parseMode(value: string): WorkflowMode | undefined {
		const normalized = value.trim().toLowerCase();
		return normalized === "read" || normalized === "plan" || normalized === "execute" ? normalized : undefined;
	}

	pi.registerCommand("mode", {
		description: "Select read, plan, or execute workflow mode",
		handler: async (args, ctx) => {
			if (!args.trim()) {
				await chooseMode(ctx);
				return;
			}
			const selected = parseMode(args);
			if (!selected) {
				ctx.ui.notify("Usage: /mode read|plan|execute", "error");
				return;
			}
			applyMode(selected, ctx);
		},
	});

	pi.registerCommand("read", {
		description: "Enter safe read/review mode",
		handler: async (_args, ctx) => applyMode("read", ctx),
	});

	pi.registerCommand("plan", {
		description: "Enter read-only planning mode",
		handler: async (_args, ctx) => applyMode("plan", ctx),
	});

	pi.registerCommand("execute", {
		description: "Enter unrestricted execution mode",
		handler: async (_args, ctx) => applyMode("execute", ctx),
	});

	pi.registerShortcut("alt+m", {
		description: "Select workflow mode",
		handler: chooseMode,
	});

	pi.registerShortcut("alt+e", {
		description: "Enter unrestricted execution mode",
		handler: (ctx) => applyMode("execute", ctx),
	});

	async function executePlanStep(stepIndex: number, ctx: ExtensionContext): Promise<void> {
		const step = planSteps[stepIndex];
		if (!step) {
			ctx.ui.notify("That plan step does not exist.", "error");
			return;
		}

		oneStepExecution = true;
		executingStep = stepIndex;
		applyMode("execute", ctx, { notify: false });
		ctx.ui.notify(`Executing step ${stepIndex + 1}/${planSteps.length}; read mode will return afterward.`, "warning");

		pi.sendUserMessage(buildExecutionPrompt(step, stepIndex));
	}

	pi.registerCommand("next", {
		description: "Execute one plan step, then return to read mode",
		handler: async (args, ctx) => {
			if (planSteps.length === 0) {
				ctx.ui.notify("No captured plan. Enter /plan and ask for a numbered plan first.", "warning");
				return;
			}

			const requested = args.trim() ? Number(args.trim()) - 1 : nextStep;
			if (!Number.isInteger(requested) || requested < 0 || requested >= planSteps.length) {
				ctx.ui.notify(`Usage: /next [1-${planSteps.length}]`, "error");
				return;
			}
			await executePlanStep(requested, ctx);
		},
	});

	pi.registerCommand("retry", {
		description: "Retry the most recently executed plan step",
		handler: async (_args, ctx) => {
			if (planSteps.length === 0 || lastExecutedStep === undefined) {
				ctx.ui.notify("There is no previously executed plan step to retry.", "warning");
				return;
			}
			await executePlanStep(lastExecutedStep, ctx);
		},
	});

	pi.registerCommand("steps", {
		description: "Show plan progress, full step details, or clear the plan",
		handler: async (args, ctx) => {
			const action = args.trim().toLowerCase();
			if (action !== "" && action !== "full" && action !== "clear") {
				ctx.ui.notify("Usage: /steps [full|clear]", "error");
				return;
			}

			if (action === "clear") {
				const hadPlan = planSteps.length > 0;
				const cleared = clearPlan();
				planSteps = cleared.planSteps;
				nextStep = cleared.nextStep;
				completedSteps = cleared.completedSteps;
				lastExecutedStep = cleared.lastExecutedStep;
				persist();
				updateStatus(ctx);
				ctx.ui.notify(hadPlan ? "Active plan cleared." : "No active plan to clear.", "info");
				return;
			}

			if (planSteps.length === 0) {
				ctx.ui.notify("No captured plan yet.", "info");
				return;
			}

			const list = renderPlanSteps(planSteps, completedSteps, nextStep, action === "full");
			ctx.ui.notify(list, "info");
		},
	});

	pi.on("before_agent_start", async (event) => {
		let instructions: string;
		if (mode === "read") {
			instructions = `[WORKFLOW MODE: READ]\nInspect and explain only. Answer questions about the code and prior work. Do not modify files, run commands, or claim to have made changes. Read-only inspection tools are available.`;
		} else if (mode === "plan") {
			instructions = `[WORKFLOW MODE: PLAN]
Investigate using read-only tools. Do not modify files or run shell commands.

If ambiguity or meaningful alternative approaches would materially affect the plan, stop and ask the user for clarification in a normal conversational response. Do not emit a Plan: section until the user has answered. Resolve minor details from the codebase when that is safe.

When the requirements are clear, end with the implementation plan in exactly this Markdown structure:

Plan:

## 1. Short step summary

A detailed Markdown description of the intended change, relevant files or components, rationale, dependencies or risks, and how the result should be verified.

## 2. Next step summary

The detailed description for the next step.

Use sequentially numbered H2 headings for every step and include a non-empty detailed body under each heading. Use H3 or lower headings for any subsections within a step.

Make each step a coherent, reviewable implementation increment that the user can understand and verify with reasonable effort before deciding whether to continue or pivot. Avoid both trivial edit-by-edit steps and overly broad steps that combine independently reviewable changes.`;
		} else if (oneStepExecution && executingStep !== undefined) {
			instructions = `[WORKFLOW MODE: EXECUTE ONE STEP]\nImplement only plan step ${executingStep + 1}. Validate that step as appropriate, report the result, and stop. Do not start a later step.`;
		} else {
			instructions = `[WORKFLOW MODE: EXECUTE]\nImplementation tools are enabled. Make the requested changes carefully, inspect files before editing, and validate the result.`;
		}
		return { systemPrompt: `${event.systemPrompt}\n\n${instructions}` };
	});

	pi.on("agent_end", async (event, ctx) => {
		if (mode !== "plan") return;
		const messages = event.messages as unknown[];
		const latestText = [...messages].reverse().map(assistantText).find(Boolean) ?? "";
		const extracted = extractPlanSteps(latestText);
		if (extracted.length === 0) return;

		const replacedExistingPlan = planSteps.length > 0;
		const replacement = replacePlan(extracted);
		planSteps = replacement.planSteps;
		nextStep = replacement.nextStep;
		completedSteps = replacement.completedSteps;
		lastExecutedStep = replacement.lastExecutedStep;
		persist();
		updateStatus(ctx);
		ctx.ui.notify(
			replacedExistingPlan
				? `Replaced the active plan with ${planSteps.length} new steps. Progress reset to step 1; use /next to begin.`
				: `Captured ${planSteps.length} plan steps. Progress starts at step 1; use /next to begin.`,
			"info",
		);
	});

	pi.on("agent_settled", async (_event, ctx) => {
		if (!oneStepExecution) return;

		if (executingStep !== undefined) {
			completedSteps.add(executingStep);
			lastExecutedStep = executingStep;
			nextStep = nextPendingStep(planSteps, completedSteps);
		}
		oneStepExecution = false;
		executingStep = undefined;
		applyMode("read", ctx, { notify: false });
		ctx.ui.notify("Step finished. READ mode restored; ask questions safely or use /next.", "info");
	});

	pi.on("session_start", async (_event, ctx) => {
		const currentTools = pi.getActiveTools();
		baselineTools = currentTools;

		let saved: SavedState | undefined;
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type === "custom" && entry.customType === "workflow-modes-v2") {
				const parsed = parseSavedState(entry.data);
				if (parsed) saved = parsed;
			}
		}

		if (saved) {
			planSteps = saved.planSteps;
			completedSteps = new Set(saved.completedSteps);
			lastExecutedStep = saved.lastExecutedStep;
			nextStep = nextPendingStep(planSteps, completedSteps);
			baselineTools = available([...currentTools, ...saved.baselineTools]);
			// Never resume a session with write access unexpectedly.
			mode = saved.mode === "plan" ? "plan" : "read";
		}

		applyMode(mode, ctx, { notify: false, save: false });
	});
}
