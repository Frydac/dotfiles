import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type WorkflowMode = "read" | "plan" | "execute";

interface SavedState {
	mode: WorkflowMode;
	planSteps: string[];
	nextStep: number;
	baselineTools: string[];
}

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

function extractPlanSteps(text: string): string[] {
	const header = /(?:^|\n)\s*(?:#{1,6}\s*)?(?:\*\*)?Plan(?:\*\*)?\s*:\s*(?:\n|$)/i.exec(text);
	if (!header || header.index === undefined) return [];

	const section = text.slice(header.index + header[0].length);
	const steps: string[] = [];

	for (const line of section.split("\n")) {
		const match = line.match(/^\s*\d+[.)]\s+(.+?)\s*$/);
		if (match?.[1]) {
			steps.push(match[1].replace(/^\*\*(.+)\*\*$/, "$1").trim());
			continue;
		}

		// Stop at the next section once numbered steps have begun.
		if (steps.length > 0 && /^\s*#{1,6}\s+/.test(line)) break;
	}

	return steps;
}

export default function workflowModes(pi: ExtensionAPI): void {
	let mode: WorkflowMode = "read";
	let baselineTools: string[] = [];
	let planSteps: string[] = [];
	let nextStep = 0;
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
		pi.appendEntry<SavedState>("workflow-modes", {
			mode,
			planSteps,
			nextStep,
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
		ctx.ui.setStatus("workflow-mode", ctx.ui.theme.fg(color, label));
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

		pi.sendUserMessage(
			`Execute only this plan step, then stop and report the result:\n\nStep ${stepIndex + 1}: ${step}\n\nDo not begin any later plan step.`,
		);
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
			const previous = Math.max(0, nextStep - 1);
			if (planSteps.length === 0 || nextStep === 0) {
				ctx.ui.notify("There is no previously executed plan step to retry.", "warning");
				return;
			}
			await executePlanStep(previous, ctx);
		},
	});

	pi.registerCommand("steps", {
		description: "Show the captured plan and execution progress",
		handler: async (_args, ctx) => {
			if (planSteps.length === 0) {
				ctx.ui.notify("No captured plan yet.", "info");
				return;
			}
			const list = planSteps
				.map((step, index) => `${index < nextStep ? "✓" : index === nextStep ? "→" : "○"} ${index + 1}. ${step}`)
				.join("\n");
			ctx.ui.notify(list, "info");
		},
	});

	pi.on("before_agent_start", async (event) => {
		let instructions: string;
		if (mode === "read") {
			instructions = `[WORKFLOW MODE: READ]\nInspect and explain only. Answer questions about the code and prior work. Do not modify files, run commands, or claim to have made changes. Read-only inspection tools are available.`;
		} else if (mode === "plan") {
			instructions = `[WORKFLOW MODE: PLAN]\nInvestigate using read-only tools. Do not modify files or run shell commands. Ask for clarification where needed. End with a detailed numbered implementation plan under exactly this heading:\n\nPlan:\n1. ...\n2. ...\n\nInclude relevant files, tests, risks, and dependencies in the steps.`;
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

		planSteps = extracted;
		nextStep = 0;
		persist();
		updateStatus(ctx);
		ctx.ui.notify(`Captured ${planSteps.length} plan steps. Use /next to execute the first one.`, "info");
	});

	pi.on("agent_settled", async (_event, ctx) => {
		if (!oneStepExecution) return;

		if (executingStep !== undefined) {
			nextStep = Math.max(nextStep, executingStep + 1);
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
			if (entry.type === "custom" && entry.customType === "workflow-modes") {
				saved = entry.data as SavedState;
			}
		}

		if (saved) {
			planSteps = Array.isArray(saved.planSteps) ? saved.planSteps : [];
			nextStep = Number.isInteger(saved.nextStep) ? saved.nextStep : 0;
			baselineTools = available([...currentTools, ...(saved.baselineTools ?? [])]);
			// Never resume a session with write access unexpectedly.
			mode = saved.mode === "plan" ? "plan" : "read";
		}

		applyMode(mode, ctx, { notify: false, save: false });
	});
}
