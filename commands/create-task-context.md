---
description: Create or update a task context file for the current feature/work
argument-hint: Task name (optional - will ask if not provided)
---

# Create Task Context

You are helping the user capture their current work context so it can be restored in future sessions.

## Process

### Step 1: Determine Task Identity

**Provided argument:** $ARGUMENTS

**If argument contains a sentence** (has spaces and >5 words, e.g., `auth-feature "Added rate limiting"`):
- Parse as: `{task-slug} "{note to append}"`
- Find existing context at `thoughts/tasks/{task-slug}.md`
- Append note to Current State section with timestamp
- Update Last Updated date
- Confirm: "✓ Added note to {task-slug} context"
- Done (skip remaining steps)

**If task name only provided:** Use it as the task slug (kebab-case).

**If no task name:** Check if there's an obvious task from the conversation. If unclear, use AskUserQuestion:
- Question: "What task/feature are you working on?"
- Header: "Task name"
- Options: "Infer from conversation" (I'll name it based on what we've discussed)

### Step 2: Check for Existing Context

Look for existing context file at `thoughts/tasks/{task-slug}.md`.

**If exists:** Read it and use AskUserQuestion to ask what kind of update:
- Question: "This task context already exists. What do you want to do?"
- Header: "Update"
- Options:
  - "Quick note" (Just append a note to Current State - fastest option)
  - "Section updates" (Choose specific sections to revise)
  - "Full refresh" (Rewrite the entire context)

If "Quick note": Ask "What should I add?" then append to Current State section and update Last Updated date. Done.

If "Section updates": Use AskUserQuestion (multiSelect: true):
- Question: "Which sections need updating?"
- Header: "Sections"
- Options: "Key files", "Decisions", "Current state", "Related docs"

If "Full refresh": Gather all information fresh.

**If new:** Gather all information.

### Step 3: Auto-Detect Related Docs

Before gathering context, scan for existing PRDs/plans that might be related:

```bash
# Look for docs with similar names to the task slug
ls thoughts/prds/*.md thoughts/plans/*.md 2>/dev/null
```

If you find docs with names matching or similar to the task slug, use AskUserQuestion:
- Question: "I found these docs that might be related. Link them to this context?"
- Header: "Link docs"
- Options: List each found doc as an option, plus "None of these"

Remember selected docs for the Related Docs section.

### Step 4: Gather Context (Brief Q&A)

Keep this fast. Use conversation history to pre-fill when possible.

**Priority order** (what matters most for restoration):
1. **Decisions Made** - Critical: prevents re-work
2. **Current State** - High: enables immediate continuation
3. **Key Files** - Medium: orientation
4. **Overview, Related Docs** - Low: background only

---

1. **Overview** - Ask only if not clear from conversation:
   "In 1-2 sentences, what are you building? (Be specific—avoid 'working on the feature')"

2. **Key Files** - Suggest from recent activity:
   "Which files are central to this task? I noticed you've been working with: [list recent files]. For each, what's its role? (Don't just list paths—explain why it matters)"

3. **Decisions Made** - Ask:
   "What key decisions have you made? For each, briefly note WHY you chose that approach over alternatives. (Things future-you shouldn't have to re-debate)"

4. **Current State** - Ask:
   "What's been accomplished so far? What's the next step? (Be specific enough to resume without asking 'where was I?')"

5. **Related Docs** - If not already linked via auto-detect, ask:
   "Any other PRDs, specs, or design docs to link?"

### Step 5: Quality Check

Before saving, verify the context meets these criteria:
- **Overview:** Can someone understand what's being built in <30 seconds?
- **Key Files:** Does each file have a clear role, not just a path?
- **Decisions:** Does each decision explain WHY, not just WHAT?
- **Current State:** Is it specific enough to resume without asking "where was I?"

If any section is vague or generic, ask a follow-up question to improve it.

### Step 6: Save Context

Create directory if needed:
```bash
mkdir -p thoughts/tasks
```

Write to `thoughts/tasks/{task-slug}.md` using this format:

```markdown
# Task: {Feature Name}

**Status:** in-progress
**Last Updated:** {today's date}
**Tracked Files:** {comma-separated list for staleness detection}

## Overview
{1-2 sentence description}

## Key Files
- `path/to/file` - {brief role}

## Decisions Made
- **[What you decided]**: [Why - what alternatives you considered]

## Current State
{Summary of work completed}

## Related Docs
- {Links if any, or remove section}
```

**Important constraints:**
- Keep total length ~20-30 lines (glanceable)
- Each section should be concise - bullets over paragraphs
- Decisions should capture the "why" not just the "what"

### Step 7: Confirm

After saving, output:

```
✓ Task context saved: thoughts/tasks/{task-slug}.md

To load this context in a new session: /use-task-context {task-slug}
```

## Proactive Update Reminder

If significant work has been done in this session and the user hasn't updated context, you may gently ask:

"Should I update the task context before we wrap up?"

But only ask once per session, and only if there were meaningful changes.
