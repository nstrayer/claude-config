# PRD: Task Context Commands

**Status:** Ready for Implementation
**Created:** 2026-01-30

## Problem Statement

Power users working on multiple features across many Claude Code sessions experience significant friction from context loss. Each new session requires manually re-explaining what feature is being built, which files are involved, what decisions have been made, and the current status. This happens multiple times daily and meaningfully slows development velocity.

Existing solutions don't fit:
- **CLAUDE.md** is project-wide, not task-scoped
- **Session history** is too noisy and includes irrelevant details
- **Manual re-typing** is error-prone and mentally taxing

Users need **task-scoped context** that persists across sessions but has its own lifecycle (features start and end).

## Target Users

Developers who:
- Use Claude Code as their primary coding assistant
- Work on multiple features in parallel within the same project
- Start new sessions frequently (multiple times per day)
- Want lightweight, controlled context rather than full session replay

## Current Alternatives

1. **Manual typing from memory** - Error-prone, tedious, inconsistent quality
2. **Winging it and correcting** - Backtracking wastes time, Claude may go down wrong paths
3. **Copy-pasting from external notes** - Context switching, keeping notes updated is another chore
4. **Using /resume** - Too much noise, can't curate what's relevant

## Proposed Solution

Two commands that manage task context files stored in `thoughts/tasks/`:

### `/create-task-context`

Creates or updates a task context file. The command should:

1. Ask for task/feature name (or infer from conversation if obvious)
2. Gather key information through brief Q&A:
   - What is being built? (1-2 sentence description)
   - Which files are involved? (can read from recent activity)
   - What key decisions have been made?
   - What's the current status/next steps?
   - Any linked PRDs or specs? (optional)
3. Save to `thoughts/tasks/{task-slug}.md` with structured format
4. If file exists, offer to update specific sections rather than replace everything

### `/use-task-context`

Loads task context at session start. The command should:

1. List available task contexts (from `thoughts/tasks/`)
2. Let user select which task(s) to load
3. Read and internalize the context
4. Summarize what Claude now understands about the task
5. Optionally note if context seems stale and offer to update

### Context File Format

```markdown
# Task: {Feature Name}

**Status:** {in-progress | paused | blocked | complete}
**Last Updated:** {date}

## Overview
{1-2 sentence description of what's being built}

## Key Files
- `path/to/file.ts` - {brief role}
- `path/to/other.ts` - {brief role}

## Decisions Made
- {Decision 1 and rationale}
- {Decision 2 and rationale}

## Current State
{What's done, what's next, any blockers}

## Related Docs
- {Link to PRD if exists}
- {Link to spec if exists}
```

### Update Behavior

When context might be stale:
- At end of significant work, Claude should proactively ask: "Should I update the task context?"
- `/create-task-context` on existing task shows diff of what changed
- Context files include "Last Updated" to surface staleness

## Success Criteria

1. **Zero re-explanation** - New sessions start immediately productive; Claude understands the ongoing work without manual setup
2. **Consistent quality** - Context is always complete and accurate; no gaps that require filling in
3. **Easy switching** - Users can jump between multiple active features by loading different contexts
4. **Low friction** - Creating/updating context takes < 1 minute and feels natural

## Non-Goals

- **Auto-detection** - Won't try to magically infer what user is working on; explicit invocation only
- **Cross-project contexts** - Scoped to current project/repo only
- **Team collaboration** - Personal workflow, not shared task management
- **Issue tracker integration** - No sync with Jira/Linear/GitHub Issues
- **Full knowledge graph** - Keeping it simple: no dependencies, blockers, timelines

## Design Decisions (Resolved)

1. **Staleness detection** - Based on file changes, not time. When loading context, proactively prompt to update if tracked files have been modified since last update. No nagging during work.

2. **Multi-task sessions** - Rare edge case. Optimize for single context with switching. No complex multi-context merging needed.

3. **Archival** - Manual cleanup by user. Status field tracks completion (status=complete), no automatic archiving or folder movement.

4. **Context size** - Glanceable (~20-30 lines). Brevity is a feature. Keep sections concise.
