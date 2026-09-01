export type WorkflowMode = "read" | "plan" | "execute";

export interface PlanStep {
	heading: string;
	details: string;
}

export interface SavedState {
	mode: WorkflowMode;
	planSteps: PlanStep[];
	nextStep: number;
	completedSteps: number[];
	lastExecutedStep?: number;
	baselineTools: string[];
}

export interface PlanProgress {
	planSteps: PlanStep[];
	nextStep: number;
	completedSteps: Set<number>;
	lastExecutedStep?: number;
}

export function replacePlan(planSteps: PlanStep[]): PlanProgress {
	return { planSteps, nextStep: 0, completedSteps: new Set<number>(), lastExecutedStep: undefined };
}

export function clearPlan(): PlanProgress {
	return replacePlan([]);
}

export function nextPendingStep(planSteps: PlanStep[], completedSteps: ReadonlySet<number>): number {
	const pending = planSteps.findIndex((_step, index) => !completedSteps.has(index));
	return pending === -1 ? planSteps.length : pending;
}

export function renderPlanSteps(
	planSteps: PlanStep[],
	completedSteps: ReadonlySet<number>,
	nextStep: number,
	full: boolean,
): string {
	const marker = (index: number): string =>
		completedSteps.has(index) ? "✓" : index === nextStep ? "→" : "○";
	return full
		? planSteps
				.map((step, index) => `## ${index + 1}. ${step.heading} ${marker(index)}\n\n${step.details}`)
				.join("\n\n")
		: planSteps.map((step, index) => `${marker(index)} ${index + 1}. ${step.heading}`).join("\n");
}

export function buildExecutionPrompt(step: PlanStep, stepIndex: number): string {
	return `Execute only this plan step, then stop and report the result:\n\n## ${stepIndex + 1}. ${step.heading}\n\n${step.details}\n\nValidate the completed work as appropriate for this step. Do not begin any later plan step.`;
}

export function parseSavedState(value: unknown): SavedState | undefined {
	if (!value || typeof value !== "object") return undefined;
	const candidate = value as Partial<SavedState>;
	if (candidate.mode !== "read" && candidate.mode !== "plan" && candidate.mode !== "execute") return undefined;
	if (!Array.isArray(candidate.planSteps)) return undefined;

	const planSteps: PlanStep[] = [];
	for (const step of candidate.planSteps) {
		if (!step || typeof step !== "object") return undefined;
		const structured = step as Partial<PlanStep>;
		if (typeof structured.heading !== "string" || !structured.heading.trim()) return undefined;
		if (typeof structured.details !== "string" || !structured.details.trim()) return undefined;
		planSteps.push({ heading: structured.heading, details: structured.details });
	}

	if (!Number.isInteger(candidate.nextStep) || candidate.nextStep! < 0 || candidate.nextStep! > planSteps.length) {
		return undefined;
	}
	if (!Array.isArray(candidate.baselineTools) || !candidate.baselineTools.every((tool) => typeof tool === "string")) {
		return undefined;
	}

	// Upgrade only older structured v2 entries. V1 string plans were rejected above.
	const rawCompleted = candidate.completedSteps ?? Array.from({ length: candidate.nextStep! }, (_, index) => index);
	if (
		!Array.isArray(rawCompleted) ||
		!rawCompleted.every((index) => Number.isInteger(index) && index >= 0 && index < planSteps.length)
	) {
		return undefined;
	}
	const completedSteps = [...new Set(rawCompleted)].sort((a, b) => a - b);
	const lastExecutedStep = candidate.lastExecutedStep;
	if (
		lastExecutedStep !== undefined &&
		(!Number.isInteger(lastExecutedStep) || lastExecutedStep < 0 || lastExecutedStep >= planSteps.length)
	) {
		return undefined;
	}

	return {
		mode: candidate.mode,
		planSteps,
		nextStep: candidate.nextStep!,
		completedSteps,
		lastExecutedStep,
		baselineTools: [...candidate.baselineTools],
	};
}

export function extractPlanSteps(text: string): PlanStep[] {
	const normalized = text.replace(/\r\n?/g, "\n");
	const header = /(?:^|\n)[ \t]*Plan:[ \t]*(?:\n|$)/i.exec(normalized);
	if (!header || header.index === undefined) return [];

	const section = normalized.slice(header.index + header[0].length);
	const lines = section.split("\n");
	const steps: PlanStep[] = [];
	let current: { heading: string; body: string[] } | undefined;
	let fence: { marker: "`" | "~"; length: number } | undefined;

	function finishCurrent(): boolean {
		if (!current) return true;
		const details = current.body.join("\n").trim();
		if (!details) return false;
		steps.push({ heading: current.heading, details });
		return true;
	}

	for (const line of lines) {
		const fenceMatch = line.match(/^\s*(`{3,}|~{3,})/);
		if (fenceMatch?.[1]) {
			const marker = fenceMatch[1][0] as "`" | "~";
			if (!fence) fence = { marker, length: fenceMatch[1].length };
			else if (marker === fence.marker && fenceMatch[1].length >= fence.length) fence = undefined;
			if (!current) return [];
			current.body.push(line);
			continue;
		}

		if (!fence) {
			const stepHeading = line.match(/^##[ \t]+(\d+)\.[ \t]+(.+?)[ \t]*$/);
			if (stepHeading?.[1] && stepHeading[2]?.trim()) {
				if (!finishCurrent()) return [];
				if (Number(stepHeading[1]) !== steps.length + 1) return [];
				current = { heading: stepHeading[2].trim(), body: [] };
				continue;
			}
			if (/^##(?:\s|$)/.test(line)) return [];
		}

		if (!current) {
			if (line.trim()) return [];
			continue;
		}
		current.body.push(line);
	}

	if (fence || !current || !finishCurrent()) return [];
	return steps;
}
