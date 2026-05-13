---
name: branch-quality-review
description: Use when a branch is feature-complete and needs a deep quality pass before merge -- checks architectural depth, test value, and decision clarity
---

# Branch Quality Review

Three-pass review of branch changes. Fix inline, flag judgment calls.

## Workflow

1. `git log main..HEAD --format="%h %s%n%b%n---"`, `git diff main...HEAD --stat`. `$ARGUMENTS` overrides base.
2. Read all changed files. Explore agent for large diffs (>10 files).
3. Run three passes. Fix what's clear, flag what needs judgment.
4. Run tests after fixes. Summarize as **Fixed** (`file:line` cited) and **Flagged** (issue + suggested resolution).

## Pass 1: Architecture

Apply improve-codebase-architecture vocabulary (module, depth, seam, locality, leverage):

- **Deletion test**: would removing an abstraction concentrate or scatter complexity?
- Shallow modules (interface ~= implementation)? Inline them.
- Speculative seams (one adapter)? Remove.
- Pass-throughs adding interface without depth? Inline.

## Pass 2: Test Value

- Tests must target the **interface**, not internals.
- Each test must catch a real failure mode -- not mirror the implementation.
- Delete tests that only add coverage percentage. Add tests for actual risk paths.

## Pass 3: Decision Clarity

- Every non-obvious "why this way?" must be answerable from naming, structure, or a one-line comment.
- Flag decisions requiring oral tradition. Suggest CONTEXT.md/ADR entries for load-bearing choices.

## Rules

- If branch is solid, say so and stop. Don't pad.
- Cite `file:line` for every finding.
