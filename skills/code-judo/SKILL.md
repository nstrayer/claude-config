---
name: code-judo
disable-model-invocation: true
description: Branch-scoped redesign that escapes a local minimum with behavior-preserving code judo -- deep modules, no leaks. Auto-applies trivial moves, proposes structural ones.
---

# Code Judo

The branch works. That is the trap. Code that works stops getting redesigned, so it settles into a **local minimum**: a shape that passes tests but leaks across its seams and stays shallow. **Code judo** is the move out -- a restructuring that uses the existing architecture better to delete complexity, while keeping behavior identical. Always measured against `main`.

The target shape is a **deep module** with no **leak**: a small interface hiding a lot of behavior, callers that never reach past it. The constraint that makes this judo and not a rewrite: every move is **behavior-preserving**.

Vocabulary -- **module, interface, seam, depth, leverage, locality** -- is defined in [`../codebase-design/SKILL.md`](../codebase-design/SKILL.md).

## Setup

1. `git diff <base>...HEAD --stat` then `git diff <base>...HEAD` to scope the change (`<base>` defaults to `main`; first non-flag argument overrides it).
2. Read every changed file. Use an Explore agent for large diffs (>10 files).
3. `--read-only`: propose everything, apply nothing.

## Step 1 -- Find the local minimum

Hunt the spots where the branch chose *works* over *deep*:

- **Leaks** -- callers that must know the module's internals (ordering, state, representation) to use it.
- **Shallow modules** -- interface nearly as complex as the implementation.
- **Ad-hoc branching** -- one-off conditionals or special cases bolted onto an existing flow.
- **Wrappers** -- indirection that adds interface without adding depth.
- **Bloat** -- a file ballooning past a healthy size (~1000 lines), speculative flexibility nothing uses, or logic duplicating a canonical helper / sitting in the wrong layer.

Apply the **deletion test** to each suspect: does removing it concentrate complexity, or just scatter it? Scattered complexity is the local minimum.

Tag every spot **trivial** (a clear, local move -- inline a pass-through, drop a dead flag) or **structural** (changes a module's shape or who owns state).

*Done when:* every awkward spot in the diff is named and tagged. Nothing in the diff left unaccounted.

## Step 2 -- Diverge

This step escapes the minimum.

For each **structural** spot: **the first fix that comes to mind is the local minimum.** Refuse it. It polishes the current shape; you want a different shape. Generate at least two genuinely different shapes -- flip the seam, invert who owns the state, collapse a special case into the default flow, delete a whole layer. Not tidier versions of what exists.

When the design space is wide enough to be worth parallel exploration, use the sub-agent divergence pattern in [`../codebase-design/DESIGN-IT-TWICE.md`](../codebase-design/DESIGN-IT-TWICE.md).

*Done when:* each structural spot has >=2 alternatives that each change the seam, state ownership, or layer count (not tidier versions of the current shape), **or** an explicit verdict that its current shape is already deep.

## Step 3 -- Decide

- **Trivial** moves: apply automatically.
- **Structural** moves: propose to the user -- the divergent options, a strong recommendation with reasoning, and a one-line note on why it is **behavior-preserving**. One decision at a time. Apply on approval.

*Done when:* every structural spot has a decision -- proposed-and-resolved or auto-applied. No tagged spot left hanging.

## Step 4 -- Apply and verify behavior preserved

Before applying any structural move that crosses a dependency seam, read [`../codebase-design/DEEPENING.md`](../codebase-design/DEEPENING.md) for the port categories and replace-don't-layer discipline -- applying without it risks layering new indirection instead of replacing the old shape.

Code judo is **behavior-preserving** by definition, so prove it: run the branch's tests and confirm behavior matches `main`. A move that changes behavior is a bug, not judo -- revert it.

*Done when:* behavior matches `main` and every applied move is accounted for.

## Finishing

Summarize, citing `file:line`:

- **Applied** -- the trivial moves.
- **Proposed and applied** -- the chosen shape per structural spot.
- **Left as-is** -- spots whose shape was already deep.

If the branch was already deep, say so and stop. Don't pad.
