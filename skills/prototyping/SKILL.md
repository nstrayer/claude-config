---
name: prototyping
description: Use when the user wants to quickly prototype an idea, build a rough proof-of-concept, explore a concept, or try something out fast. Also use when the user says /prototype.
---

# Rapid Prototyping

**SHIP SOMETHING TRYABLE. DECIDE IF IT'S WORTH BUILDING PROPERLY LATER.**

**Announce at start:** "Entering prototype mode -- prioritizing speed over polish."

## Override: Skip Process Skills

**Do NOT invoke:** brainstorming, writing-plans, executing-plans, test-driven-development, requesting-code-review, verification-before-completion, subagent-driven-development.

**Still respect:** Security basics (no SQLi, XSS), existing project structure, user's CLAUDE.md.

## When to Use

- Trying an idea before committing to building it properly
- Exploring feasibility, building a demo for feedback
- User says "prototype", "spike", "hack together", "try it out"

**NOT:** Security-critical features, prod data, database migrations. If the user doesn't know *what* to build, use brainstorming first. If the task is small enough to just do properly, skip prototype mode.

## The Process

### Step 1: Create Branch

Create `prototype/<name>` branch off current HEAD before touching code.

### Step 2: Gather Requirements

Ask questions **one at a time** (happy path, where it lives, what user sees). ~3 questions max, bias toward starting. Stop when the user says "go" or you have enough for a reasonable first pass.

### Step 3: Build Fast

Once building, don't pause to ask -- guess and go.

- Implement in the real codebase, follow existing patterns loosely
- Duplicate code > abstracting. Skip tests, skip non-happy-path error handling.
- Use `// HACK:` and `// TODO:` comments for rough spots
- Commit as you go: `prototype: <what>`
- Pick the straightforward path. Don't refactor, add types (unless required), or optimize.
- If scope balloons, cut to the smallest demonstrable slice

### Step 4: Wrap Up

Summarize: (1) what was built, (2) how to try it, (3) what's hacky, (4) what needs work for production.

Ask: "Want me to write this up as a transition doc?" If yes, commit a markdown summary to the prototype branch in a location that fits the project.

## When Stuck

| Blocker | Do this |
|---------|---------|
| Needs API key / auth | Hardcode mock responses, stub it |
| Missing dependency | Use what's available or simplify scope |
| Unclear requirement | Best guess, note the assumption |

## After Prototyping

- **Build properly:** Promote the branch, use brainstorming/planning skills
- **Throw away:** Delete branch, take learnings forward
- **Keep exploring:** Continue hacking on the prototype branch

## Red Flags -- You're Overthinking It

| Thought | What to do instead |
|---------|-------------------|
| "I should write tests for this" | No. Build it, try it manually. |
| "Let me refactor this first" | No. Work with what's there. |
| "This needs a proper abstraction" | No. Inline it. Duplicate if needed. |
| "I should handle this edge case" | No. Happy path only. |
| "Let me check if there's a better library" | Use what's already in the project. |
| "This won't scale" | It doesn't need to. It's a prototype. |
| "I need a design doc" | You're in prototype mode. Just build. |
| "Let me add types for this" | Only if the compiler demands it. |
