---
name: branch-quality-review
description: Use when a branch is feature-complete and needs a deep quality pass before merge -- checks architectural depth, test value, and decision clarity
---

# Branch Quality Review

Deep review of a branch's work across three lenses: architectural depth, test value, and decision explainability. Fixes issues inline and summarizes what changed.

## Workflow

1. **Gather context**: `git log main..HEAD --format="%h %s%n%b%n---"`, `git diff main...HEAD --stat`. Use `$ARGUMENTS` as base if provided.
2. **Read all changed files** end-to-end. Use Explore agent for large diffs (>10 files or >2k lines).
3. **Run three review passes** (see below).
4. **Fix inline** what you can. For judgment calls that need user input, flag them.
5. **Summarize**: short list of what was fixed and what remains flagged.

## Pass 1: Architecture (invoke improve-codebase-architecture lens)

Apply the improve-codebase-architecture skill's vocabulary and principles to the branch's changes:

- Are new modules **deep** (lots of behavior behind a small interface) or shallow?
- **Deletion test**: if you deleted a new abstraction, would complexity concentrate or scatter?
- Are seams real (two adapters) or speculative (one implementation behind an interface)?
- Do changes maintain **locality** -- change, bugs, and knowledge in one place?
- Are pass-through functions or thin wrappers adding interface without depth?

Fix: inline shallow modules back into their callers, remove speculative seams, consolidate scattered logic.

## Pass 2: Test Value

Every test added or modified on this branch should earn its keep:

- Does it test at the **interface**, not internals? (Reaching into private state = wrong module shape.)
- Does it catch a real failure mode, or just mirror the implementation?
- Would deleting it lose safety, or just lose coverage percentage?
- Are there missing tests for actual risk areas the branch introduces?

Fix: remove low-value tests (implementation mirrors, trivial assertions), add missing high-value tests for real risk paths, restructure tests that reach into internals to test through the public interface instead.

## Pass 3: Decision Clarity

Every non-obvious architectural choice on this branch should be explainable in one sentence:

- For each "why did they do it this way?" moment, check if the answer is evident from naming, structure, or a brief comment.
- Flag decisions that require oral tradition to understand.
- Check if the branch introduces concepts not in `CONTEXT.md` (if it exists) -- suggest additions.

Fix: rename to make intent obvious, add a one-line comment where the WHY is non-obvious, suggest CONTEXT.md or ADR entries for load-bearing decisions.

## Output

Inline response with two sections:

**Fixed** -- bulleted list of changes made, with `file:line` citations.

**Flagged** -- items needing user judgment before fixing. Each has:
- What the issue is
- Why it matters (architecture/test/clarity)
- Suggested resolution

## Rules

- Fix confidently when there's a clear right answer. Flag when it's a judgment call.
- Don't pad. If the branch is solid, say so and stop.
- Use improve-codebase-architecture vocabulary (module, interface, depth, seam, locality, leverage) -- not vague synonyms.
- Cite `file:line` for every finding.
- Run existing tests after fixes to catch regressions.
