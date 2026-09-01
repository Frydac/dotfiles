# Workflow Modes v2

## Automated checks

The v2 pure helpers use Deno's built-in checker and test runner:

```sh
deno check workflow-modes-v2-utils.ts workflow-modes-v2-utils.test.ts
deno test workflow-modes-v2-utils.test.ts
```

Pi loads `index.ts` with its own TypeScript runtime. Use `/reload` to validate the extension entry point after applying changes.

## Manual verification

With only v2 enabled:

1. Enter `/plan` and request a two-step plan containing paragraphs, a list, a nested `###` heading, and a fenced code example.
2. Run `/steps`; confirm only numbered headings and progress markers appear.
3. Run `/steps full`; confirm every detail is shown unchanged.
4. Run `/next 2`; confirm only step 2's complete heading and body are sent, then read mode returns. Confirm `/steps` marks only step 2 complete and still points at step 1.
5. Run `/retry`; confirm step 2's complete content is sent again without changing step 1's status.
6. Create another valid plan; confirm it replaces the first and all progress resets.
7. Reload or resume the session; confirm the structured plan, non-sequential completion, and retry target are restored.
8. Run `/steps clear`; confirm the plan and footer progress disappear and remain cleared after reload.
9. In plan mode, produce a malformed plan (legacy numbered lines, missing body, skipped number, or unclosed fence); confirm it does not replace the active valid plan.
