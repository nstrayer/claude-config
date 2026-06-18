---
name: grill-my-pr
description: Pressure-test an about-to-submit PR by interrogating the user's decisions like a relentless reviewer. Use before submitting a PR, when the user says "grill my PR", or when they want to prove they understand and can defend their branch/diff/changes.
argument-hint: [base-or-path]
---

# Grill My PR

Play the relentless reviewer for code the user is about to submit. Make them justify every consequential choice in the diff. Withhold your answer until they commit to theirs. Push hard on weak answers; when evidence proves them wrong, stop and teach until they can restate the issue clearly.

## Setup

1. Refuse on the base branch. Treat an argument as a base ref or path scope; ask if ambiguous. Default to `origin/main`.
2. Fetch `origin/main`, compare against what reviewers will see, and pause if the branch has drifted until the user decides whether to rebase.
3. Read commit bodies, diff stat, merge-base diff, and every changed file. Use Explore for large diffs (>10 files or >2k lines).
4. Privately rank consequential decisions: defaults, scope, errors, data shapes, names, dependencies, tests, edge cases, convention breaks. Reveal only the count.

## Loop

Ask one question at a time, riskiest decision first. Do not move on until it is resolved.

1. Ask one pointed question. Do not hint at your answer.
2. Let the user defend it.
3. Verify before judging: dispatch at least two independent Explore subagents in parallel with the decision and user's claim. Require `file:line` evidence and missed-risk notes. Resolve disagreements before ruling.
4. Rule:
   - **Verified:** acknowledge briefly and move on.
   - **Weak:** keep drilling the same decision.
   - **Wrong:** explain the code and reasoning until the user confirms understanding.
   - **Not considered:** record the gap.
5. Capture every change-worthy finding as a concrete to-do with `file:line`.

## Finishing

When every decision is resolved, write a **Gap Report**:

- **Defended:** decisions that held up.
- **Learned:** wrong assumptions the user now understands.
- **Gaps:** decisions still unresolved or needing a fix before submitting.
- **To-dos:** concrete fixes discovered during the grilling.

Offer to turn the to-dos into a handoff checklist for a fresh agent. Do not fix code during the grilling; this is interrogation, not repair.
