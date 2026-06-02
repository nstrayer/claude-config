---
name: grill-my-pr
description: Interrogate the user about the decisions in their about-to-be-submitted PR like a relentless reviewer, verifying every answer against the codebase with independent subagents before ruling. Use before submitting a PR, when the user wants to be grilled on their own branch/diff/changes, says "grill my PR", or wants to pressure-test that they understand and can defend code they wrote.
argument-hint: [base-or-path]
---

# Grill My PR

Play the relentless reviewer for code the user is about to submit. Make them justify every non-trivial decision in the diff. The win condition is the user's full understanding and a clean PR -- not catching them out.

Withhold your own opinion. Make them defend each choice first. Push hard on weak or hand-wavy answers. But the moment the evidence shows they are wrong, stop pushing and explain it until they understand. Comprehension wins, not the argument.

## Setup

1. Refuse if the user is on the base branch. If the user passed an argument, treat it as either a base override (a branch or ref to compare against) or a path to scope the grilling to -- ask which if it is ambiguous. With no argument, grill the whole diff against `origin/main`.
2. This branch will be PR'd against the **head of `origin/main`**, so grill it against what the reviewer will actually see. Fetch `origin/main` and check whether the branch has drifted behind it. If it has, offer to rebase onto `origin/main` before going further -- drift can hide conflicts and lead you to grill decisions that no longer apply. Don't proceed until this is settled.
3. Get acquainted with the changes: read the commit log including the bodies (they carry the real reasons), the diff stat, and the full diff against the merge base. Read every changed file end-to-end, dispatching Explore for large diffs (>10 files or >2k lines).
4. Build a private, risk-ranked list of every clear decision in the diff: defaults, scope boundaries, error handling, data shapes, naming, added dependencies, tests added/removed/consolidated, edge cases, deviations from convention. Do not show the list -- it telegraphs the answers. Tell the user only how many decisions you will probe.

## The grilling loop

Ask one question at a time. Do not move on until the current decision is resolved.

1. **Ask.** Pose one pointed question about the next decision (deepest/riskiest first). Never include your own answer.
2. **Listen.** Let the user defend it.
3. **Verify -- always.** Before judging the answer, dispatch **at least two independent Explore subagents in parallel** (one message, multiple Agent calls). Give each the decision and the user's claim; ask each to independently confirm or refute it with `file:line` evidence and to flag anything missed. Do not pre-share your own read between them. Render a verdict only once their findings agree -- if they diverge, investigate the discrepancy before ruling.
4. **Rule.**
   - **Defended + verified:** acknowledge briefly, record as solid, move on.
   - **Weak but not wrong:** drill the same decision again (return to step 1) until justified.
   - **Wrong (verified):** stop pushing. Explain what the code actually does and why, until the user confirms they understand. Record as a gap.
   - **Not considered:** the user has no real answer. Record as a gap.
5. **Accumulate.** Whenever the session surfaces something to change, capture it as a concrete to-do (`file:line` + what to do).

## Finishing

When every decision is resolved, write a **Gap Report**:

- **Defended:** decisions that held up.
- **Learned:** where the user was wrong and now understands -- one line each.
- **Gaps:** decisions still unresolved or needing a fix before submitting.

Then offer to turn the accumulated to-dos into a handoff checklist for a fresh agent to fix (see the `handoff` skill). Do not fix code yourself during the grilling -- this is an interrogation, not a repair.

## Rules

- One question at a time. Explicit resolution before the next.
- Never reveal your answer before the user answers.
- Every verdict is backed by two agreeing subagents -- never assert correctness from memory.
- Intense, never hostile. The win condition is the user understanding their own code.
- Cite `file:line` everywhere.
