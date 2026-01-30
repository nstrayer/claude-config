---
description: Load a task context to continue work from a previous session
argument-hint: Task name (optional - will list available if not provided)
---

# Use Task Context

You are loading a saved task context so you can continue work without the user re-explaining everything.

## Task Selection

**Provided task:** $ARGUMENTS

### If task name provided:

Look for `thoughts/tasks/{task-name}.md`. If not found, try fuzzy matching against available files in `thoughts/tasks/`.

### If no task name provided:

List available task contexts:

```bash
ls -la thoughts/tasks/*.md 2>/dev/null
```

**If no tasks exist:** Tell the user and suggest `/create-task-context`.

**If tasks exist:** Use AskUserQuestion to let user select:
- Question: "Which task context do you want to load?"
- Header: "Task"
- Options: Generate from available files, each showing "{task-name}" ({status} - Last updated {date})

## Loading the Context

1. **Read the context file** completely

2. **Internalize the context** - Read and understand:
   - What's being built (Overview)
   - Which files matter (Key Files)
   - What's already been decided (Decisions Made)
   - Where we left off (Current State)
   - Any reference docs to be aware of

## Output

Provide a brief acknowledgment that shows you understand the context:

```
## Loaded: {Task Name}

**Building:** {1-sentence overview}
**Key files:** {list the main 2-3 files}
**Left off at:** {current state summary}
**Decisions to remember:** {key decisions in brief}
**Related docs:** {list any linked PRDs/plans, or omit if none}

Ready to continue. What would you like to work on?
```

If there are related docs linked, also read them to have full context. Mention them so the user knows you have that background:
- "I've also read the linked PRD at thoughts/prds/feature-x.md for full requirements."

Keep this summary tight - the point is to confirm understanding, not repeat the whole file back.

## Maintaining Context During Work

As you work, keep the task context file updated with meaningful changes. Don't announce updates or ask permission—just update the file quietly when appropriate.

**Update when:**
- You choose between 2+ approaches (add to Decisions with rationale)
- A feature or component works end-to-end (update Current State)
- You create a new file or heavily modify one the user should know about (add to Key Files)
- Something you tried didn't work and you changed direction (note the pivot)

**Don't update for:**
- Debugging steps that led nowhere
- Refactors that don't change the overall approach
- Reading files or exploring the codebase
- Minor fixes within the existing approach

Keep updates concise—a bullet point, not a paragraph. The goal is that if this session ends unexpectedly, the context file reflects where things actually stand.

## Important Behaviors

- **Single context at a time** - If asked to load a different context mid-session, that's a context switch. Acknowledge you're now focused on the new task.
- **Don't over-read** - You've internalized the context; don't keep referencing the file unless specifically needed.
