# Philosophy for work

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

State assumptions instead of guessing; when uncertain or unclear, stop and ask rather than pick silently. If multiple interpretations exist, present them. If a simpler approach exists, say so and push back.

## 2. Deep Modules

Prefer deep modules at every scale: a lot of behavior behind a small interface.

- **Deletion test.** Imagine deleting the module. If complexity moves to callers, don't extract. If it would reappear across N callers, the module earns its keep.
- **Concentrate knowledge.** Change, bugs, and understanding live in one place. Don't spread implementation details across callers via leaky interfaces.
- **No speculative abstractions.** Don't introduce a seam unless something actually varies across it. One implementation = hypothetical. Two (e.g., production + test fake) = real.
- **Test at the interface.** If you need to reach into internals to test, the module is the wrong shape.
- **Inline pass-throughs.** A function that delegates to another with the same signature adds interface without depth.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define a checkable success criterion, then loop until it's met.** Recast vague tasks into a verifiable goal (a test that fails then passes, a suite green before and after) so you can verify independently instead of asking "is this working?"


## General Guidelines
- Ask simple to the point questions. If the answers are clear and simple use the AskUserQuestion tool. Don't overwhelm with a bunch of questions at once. 
- Avoid unicode characters (em dashes, smart quotes, etc.) in code and text.
- Some projects use `thoughts/agent-notes/` for development notes from past sessions -- architectural decisions, non-obvious patterns, gotchas, and API contracts. Check here for context before working on a subsystem.
- After every meaningful unit of work, commit the changes with a short and descriptive commit message.
- gh requests the deprecated `projectCards` field, so commands that read PR/issue metadata (`gh pr|issue view|list|edit`) can hit a "Projects (classic) is being deprecated" GraphQL error -- usually a harmless warning on reads, but on `edit`/mutations it can silently abort the change (the command appears to run, yet nothing changes).
- Make PR/issue body or field mutations via REST to sidestep it: `gh api repos/{owner}/{repo}/pulls/{number} -X PATCH -F body=@body.md`. Scope reads with `--json <fields>` to avoid project fields, and verify a mutation actually applied (e.g. `gh pr view N --json body`).
