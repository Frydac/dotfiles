import {
	buildExecutionPrompt,
	clearPlan,
	extractPlanSteps,
	nextPendingStep,
	parseSavedState,
	renderPlanSteps,
	replacePlan,
	type PlanStep,
} from "./workflow-modes-v2-utils.ts";

function assert(condition: unknown, message = "assertion failed"): asserts condition {
	if (!condition) throw new Error(message);
}

function assertEquals(actual: unknown, expected: unknown, message = "values differ"): void {
	const actualJson = JSON.stringify(actual);
	const expectedJson = JSON.stringify(expected);
	if (actualJson !== expectedJson) throw new Error(`${message}\nexpected: ${expectedJson}\nactual:   ${actualJson}`);
}

const steps: PlanStep[] = [
	{ heading: "Parse plans", details: "Update `parser.ts`.\n\n- Preserve lists\n- Verify output" },
	{ heading: "Render plans", details: "Show the complete body." },
];

Deno.test("extracts multiline steps with nested Markdown and lists", () => {
	const parsed = extractPlanSteps(`Intro\n\nPlan:\n\n## 1. Parse plans\n\nUpdate \`parser.ts\`.\n\n### Risks\n\n- Preserve lists\n- Keep file references\n\n## 2. Verify behavior\n\nRun focused checks.\n\n1. Parser test\n2. Rendering test`);
	assertEquals(parsed, [
		{
			heading: "Parse plans",
			details: "Update `parser.ts`.\n\n### Risks\n\n- Preserve lists\n- Keep file references",
		},
		{ heading: "Verify behavior", details: "Run focused checks.\n\n1. Parser test\n2. Rendering test" },
	]);
});

Deno.test("preserves fenced code blocks including apparent step headings", () => {
	const parsed = extractPlanSteps(`Plan:\n\n## 1. Preserve examples\n\n\`\`\`md\n## 99. Not a real step\n- example\n\`\`\`\n\nContinue after the fence.`);
	assertEquals(parsed, [
		{
			heading: "Preserve examples",
			details: "```md\n## 99. Not a real step\n- example\n```\n\nContinue after the fence.",
		},
	]);
});

Deno.test("rejects missing and malformed step headings", () => {
	assertEquals(extractPlanSteps("No plan here"), []);
	assertEquals(extractPlanSteps("Plan:\n\n1. Legacy one-line step"), []);
	assertEquals(extractPlanSteps("Plan:\n\n## 2. Starts at two\n\nDetails"), []);
	assertEquals(extractPlanSteps("Plan:\n\n## 1. Missing body"), []);
	assertEquals(extractPlanSteps("Plan:\n\n## Unnumbered\n\nDetails"), []);
	assertEquals(extractPlanSteps("Plan:\n\n## 1. Open fence\n\n```ts\nconst x = 1;"), []);
});

Deno.test("replacement resets stale completion and retry progress", () => {
	const replacement = replacePlan(steps);
	assertEquals(replacement.planSteps, steps);
	assertEquals(replacement.nextStep, 0);
	assertEquals([...replacement.completedSteps], []);
	assertEquals(replacement.lastExecutedStep, undefined);
});

Deno.test("renders compact headings and complete full bodies", () => {
	const completed = new Set([0]);
	assertEquals(renderPlanSteps(steps, completed, 1, false), "✓ 1. Parse plans\n→ 2. Render plans");
	const full = renderPlanSteps(steps, completed, 1, true);
	assert(full.includes("## 1. Parse plans ✓\n\nUpdate `parser.ts`.\n\n- Preserve lists\n- Verify output"));
	assert(full.includes("## 2. Render plans →\n\nShow the complete body."));
});

Deno.test("clearing removes plan and all progress", () => {
	const cleared = clearPlan();
	assertEquals(cleared.planSteps, []);
	assertEquals(cleared.nextStep, 0);
	assertEquals([...cleared.completedSteps], []);
	assertEquals(cleared.lastExecutedStep, undefined);
});

Deno.test("restores structured persistence and rejects v1 string plans", () => {
	const restored = parseSavedState({
		mode: "read",
		planSteps: steps,
		nextStep: 0,
		completedSteps: [1],
		lastExecutedStep: 1,
		baselineTools: ["read", "grep"],
	});
	assert(restored);
	assertEquals(restored.completedSteps, [1]);
	assertEquals(restored.lastExecutedStep, 1);
	assertEquals(nextPendingStep(restored.planSteps, new Set(restored.completedSteps)), 0);
	assertEquals(
		parseSavedState({ mode: "read", planSteps: ["legacy"], nextStep: 0, baselineTools: ["read"] }),
		undefined,
	);
});

Deno.test("upgrades older structured v2 prefix progress", () => {
	const restored = parseSavedState({ mode: "plan", planSteps: steps, nextStep: 1, baselineTools: ["read"] });
	assert(restored);
	assertEquals(restored.completedSteps, [0]);
});

Deno.test("execution prompt includes the complete selected step and boundary", () => {
	const prompt = buildExecutionPrompt(steps[0], 0);
	assert(prompt.includes("## 1. Parse plans"));
	assert(prompt.includes("Update `parser.ts`.\n\n- Preserve lists\n- Verify output"));
	assert(prompt.includes("Validate the completed work as appropriate"));
	assert(prompt.includes("Do not begin any later plan step."));
});
