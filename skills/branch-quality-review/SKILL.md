---
name: branch-quality-review
description: Pre-PR review loop for branch or diff changes -- find bugs first, then improve design (deepen modules, simplify). Use for any on-demand review of a branch, diff, or PR's code. --read-only for findings-only (someone else's code).
---

# Branch Quality Review

The pre-PR review loop, run in order: **bugs** first, then **design**. Pass 1 finds what's wrong; Pass 2 follows `code-judo` to improve the shape. Other review skills call this one -- keep it self-contained.

Default: fix what's clearly wrong inline, flag what needs judgment. `--read-only` flips this to findings-only (use when reviewing someone else's code).

## Arguments

- `--read-only`: make NO edits. Note findings only. The author decides what to act on.
- A non-flag argument overrides the base ref (default: `main`). Any other `--flag` is ignored.

## Setup

1. `git log <base>..HEAD --format="%h %s%n%b%n---"`, `git diff <base>...HEAD --stat` to scope the change.
2. Read every changed file. Use an Explore agent for large diffs (>10 files).
3. **Repo-specific patterns.** Derive the repo key:
   ```bash
   basename "$(git remote get-url origin 2>/dev/null | sed 's/\.git$//')"
   ```
   If `~/.claude/review-patterns/<key>/` exists, read every `.md` file in it and fold those checks into the passes below. If the directory does not exist, skip this step silently -- do not mention it.

## Pass 1: Bugs

Correctness, safety, and the tests that guard them.

- **Logic**: off-by-one, wrong conditionals, race conditions, bad state transitions, unreachable branches.
- **Types**: `any`, unsafe assertions (`as unknown as X`), missing narrowing, hand-maintained unions a library already types.
- **Null/undefined**: optional values accessed without a guard where `?.`/`??` would prevent a runtime error.
- **Errors**: silently swallowed errors, missing try/catch around async, `.then()` where `.finally()` is needed for cleanup, unhandled rejections.
- **Resource cleanup**: subscriptions, observers, or disposables not registered for teardown; leaks.
- **Test value**: each test must catch a real failure mode, not mirror the implementation. Delete coverage-only tests; add tests for actual risk paths.

Read enough surrounding context to avoid false positives (a guard may exist upstream). Surface suspicious-but-unsure patterns as questions, not just confirmed bugs.

## Pass 2: Design

Run the design pass by following the process in [`../code-judo/SKILL.md`](../code-judo/SKILL.md) against this same diff: deepen shallow modules, fix leaks across seams, and delete incidental complexity and over-engineering. That skill's decide-step already matches this skill's idiom -- it auto-applies trivial moves and proposes structural ones.

In `--read-only` mode, follow `code-judo`'s read-only variant: detect and flag the design moves, apply nothing.

## Finishing

- **Default mode**: fix clear issues inline, then run tests. Summarize as **Fixed** (`file:line` cited) and **Flagged** (issue + suggested resolution).
- **Read-only mode**: make no edits. Summarize as **Findings** (`file:line`, grouped by pass) and a one-line **Verdict**.
- Cite `file:line` for every finding.
- Flag any load-bearing decision that rests on oral tradition, and suggest a `CONTEXT.md`/ADR note for it.
- If the branch is solid, say so and stop. Don't pad.

After presenting findings (not in read-only mode), suggest `grill-my-pr` if the user wants to pressure-test that they can defend every decision before submitting.
