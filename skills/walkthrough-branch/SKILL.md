---
name: walkthrough-branch
description: Use when preparing a reviewer walkthrough for a multi-commit feature branch, before a synchronous code review, or when a reviewer needs to understand the architectural decisions and tradeoffs behind the branch's changes
---

# Walkthrough Branch

Decision-driven walkthrough doc for the current branch, intended as speaker notes during a live review. Unlike `summarize-branch`, it's organized around architectural choices with `file:line` citations, not a flat change list.

## Workflow

1. Refuse if on base branch. `$ARGUMENTS` overrides the default (main/master).
2. Gather in parallel: `git log <base>..HEAD --format="%h %s%n%b%n---"`, `git diff <base>...HEAD --stat`, `git diff <base>...HEAD --name-only`. **Commit bodies matter** - PR-review commits ("refactor: clean up from review", "fix: tighten regex") carry the real decisions.
3. Read every changed file end-to-end for accurate citations. Dispatch Explore for >10 files or >2k diff lines.
4. Ask two questions via AskUserQuestion in one call:
   - **Structure**: final-state / chronological / decision-driven
   - **Focus** (multiSelect): 3-5 candidate areas inferred from the diff
5. Write `BRANCH-WALKTHROUGH-<branch-slug>.md` at repo root (slug: `/` -> `-`). Output is always a markdown doc; audience is always a team peer (assume shared project context, skip onboarding prose).

## Output sections (decision-driven default)

- Header: branch, base, stats, issue ref if inferrable
- What's new at a glance: 2-3 sentences, file list with line counts and one-phrase role
- Decisions: one section per architectural choice. For each: **why** it exists, `file:line` pointers, tradeoff
- Testing strategy: what's covered, what was consolidated, what's missing
- Commit timeline, grouped by theme
- Suggested walkthrough order: 3-5 stops in review-session order
- Prompts for the reviewer: open questions to surface proactively

Adapt sections to the chosen structure: chronological drops per-decision headers in favor of commit-order narrative; final-state skips the timeline and leads with the end design.

## Rules

- Every architectural claim cites `file:line`. Uncited walkthroughs fail during live review.
- Lead with **why**, then **what**, then **tradeoff**.
- Derive decisions from commit bodies, not just final code.
- Never invent line numbers - re-read if output is stale.

After writing, offer to run `anticipate-review-concerns`.
