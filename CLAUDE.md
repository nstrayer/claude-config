## Core Behaviors

- Ask targeted clarifying questions when requirements are unclear
- Use AskUserQuestion tool when: asking multiple questions, offering choices between approaches, or any question with 2-4 clear options. Plain text only for truly open-ended questions with no obvious options.
- Prefer the simplest design that meets requirements; state trade-offs and risks
- Break work into small, testable pieces with clear boundaries
- Don't add features, refactor code, or make improvements beyond what was asked. If I ask you to "clean up," "improve," or "refactor," then broader changes are appropriate.
- After each turn where code changes were made, commit them unless the changes are incomplete or the user says otherwise. Split changes into logical, single-purpose commits (e.g., a refactor and a new feature should be separate commits). Use conventional commit messages (e.g., `feat:`, `fix:`, `refactor:`, `docs:`, `test:`)
- After making changes, run relevant existing tests to catch regressions.
- Use `gh pr view <num> --json <fields>` instead of bare `gh pr view <num>`; the bare form fails with a Projects (classic) deprecation GraphQL error.
- Check `--help` before using `gh` extensions (e.g. `gh pr-review`); flags differ from the base CLI and required flags aren't always obvious.


## Code Style

- Use clear names, early returns, and shallow control flow
- Avoid unicode characters (em dashes, smart quotes, etc.) in code and text.


## Architecture: Deep Modules

Prefer deep modules at every scale: a lot of behavior behind a small interface.

- **Deletion test.** Imagine deleting the module. If complexity moves to callers, don't extract. If it would reappear across N callers, the module earns its keep.
- **Concentrate knowledge.** Change, bugs, and understanding live in one place. Don't spread implementation details across callers via leaky interfaces.
- **No speculative abstractions.** Don't introduce a seam unless something actually varies across it. One implementation = hypothetical. Two (e.g., production + test fake) = real.
- **Test at the interface.** If you need to reach into internals to test, the module is the wrong shape.
- **Inline pass-throughs.** A function that delegates to another with the same signature adds interface without depth.


## Agent Notes

- `thoughts/agent-notes/` contains development notes from past sessions -- architectural decisions, non-obvious patterns, gotchas, and API contracts. Check here for context before working on a subsystem.