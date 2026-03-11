---
name: catchup
description: Get oriented after being away - understand what you were working on and where you left off
---

# Catch Up on Previous Work

You are helping the user get oriented after returning from a break. Your job is to investigate the current state of the project and reconstruct what was being worked on.

## Focus Area

**User's focus:** $ARGUMENTS

- **If focus is provided**: Filter your investigation to that area. Search for commits, files, and plans related to "$ARGUMENTS". Prioritize results matching that topic.
- **If focus is empty**: Do a general catchup across all recent work.

## Important: Scope Limits

- DO NOT start implementing anything
- DO NOT make commits, edits, or changes
- ONLY summarize and recommend next steps
- If the user wants to proceed, they will give a new instruction

## Investigation Strategy

Launch **3 parallel Explore agents** in a single message to gather context efficiently. Each agent focuses on a different information source:

### Agent 1: Git & File State

Investigate the git repository state:

```bash
# Branch and working directory
git branch --show-current
git status --short

# Recent commits (last 5-10)
git log --oneline -10

# Uncommitted changes summary
git diff --stat
git diff --cached --stat

# Stashed work
git stash list
```

Report: Current branch, uncommitted changes, recent commit themes, any stashes.

### Agent 2: Claude State (`.claude/` infrastructure)

Check Claude-specific state files in the user's home `.claude/` directory:

1. **Todos** (`~/.claude/todos/*.json`): Look for files with in-progress items
   - Parse JSON to find `"status": "in_progress"` items
   - Note the task descriptions

2. **Plans** (`~/.claude/plans/*.md`): Find recently modified plan files
   - Sort by modification time, read the most recent 1-2
   - Summarize what they're planning

3. **History** (`~/.claude/history.jsonl`): Last ~20 lines
   - Filter for entries matching the current project path
   - Extract recent prompt summaries

Report: Active todos, recent plans, last few prompts in this project.

### Agent 3: Planning Documents

Search the project for planning and work-in-progress documents:

- `thoughts/` directory (common for plans and research)
- `**/PLAN*.md`, `**/TODO*.md`, `**/WIP*.md`, `**/NOTES.md`
- `.claude/handoffs/` or `thoughts/shared/handoffs/`
- Root and `docs/` directories

Report: Any planning docs found, their key points, suggested next steps from them.

## After Investigation: Detect Scenario

Based on agent results, determine which scenario applies:

| Scenario | Indicators | Your Focus |
|----------|------------|------------|
| **Mid-implementation** | In-progress todos, uncommitted changes, active plan | Show the changes, identify next step from plan |
| **Between tasks** | Clean working dir, completed todos | Show recent plans/commits, ask what's next |
| **Long absence** | Many commits since last session, no matching todos | Summarize what changed, help reorient |

## Output Format

Present a **concise summary** (aim for scannable, not exhaustive):

### Example Output

```
## Catchup Summary

**Branch**: `feature/auth-flow` (3 uncommitted files)

**Recent Work** (from commits):
- Added login form validation
- Connected auth service to API

**In Progress**:
- Todo: "Add password reset flow" (in_progress)
- Plan: `auth-implementation.md` - Phase 2 of 3 complete

**Uncommitted Changes**:
- `src/auth/reset.ts` - new file (password reset handler)
- `src/auth/login.ts` - modified (added validation)

**Suggested Next Step**: Continue password reset flow per the plan - next is email verification.
```

## After Summary: Offer Deep-Dive

Use `AskUserQuestion` to let the user choose what to explore further:

```yaml
question: "Want me to dive deeper into any area?"
header: "Next"
options:
  - label: "Show full diff"
    description: "See the actual code changes"
  - label: "Read the plan"
    description: "Show the full implementation plan"
  - label: "Show recent context"
    description: "What we discussed last session"
  - label: "I'm caught up"
    description: "Ready to continue working"
```

## Important Notes

- Be concise but thorough - bullet points over paragraphs
- If you find planning documents, summarize their key points (don't dump full contents)
- Make educated guesses about intent based on file names and change patterns
- Present findings as a helpful colleague, not a formal report
- If the project has a `CLAUDE.md`, factor that context into your understanding
- Remember: investigate and summarize only - never start implementing