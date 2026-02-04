---
description: Generate a summary document of work done on the current branch
argument-hint: Base branch to compare against (optional, defaults to main)
---

# Summarize Branch

Generate a summary of all work done on the current branch compared to a base branch. Useful for orientation after time away, PR preparation, or progress documentation.

## Inputs

- **$ARGUMENTS**: Base branch to compare against (defaults to main/master if not provided)
- **Current branch**: Must be on a feature branch, not the base branch

## What to Gather

Use git commands to collect:
- Commit history since diverging from base (`git log base..HEAD`)
- Changed files and their diff stats
- Any uncommitted changes
- Overall additions/deletions

## Output: `BRANCH-SUMMARY-<branch-name>.md`

Create a summary document at project root with this structure:

```markdown
# Branch: <branch-name>

**Base:** <base-branch>
**Last Updated:** <date>
**Stats:** <commit count> commits, +<additions> -<deletions> across <file-count> files

---

## Overview

<2-3 sentences describing what this branch is doing, inferred from commits and changes>

## Key Files

<Most-changed files with inferred roles>

- `path/to/file` - <role>

## What Changed

<Group by area: API, UI, Data, Tests, Config, etc. - only include areas with changes>

## Commit History

<List commits, grouped by theme if many, or flat list if few>

## Current State

**Completed:** <inferred from commits>
**In Progress:** <inferred from recent work and uncommitted changes>

---

## Notes

_Space for your notes..._
```

## Important

- If on base branch, error and suggest switching to a feature branch
- If no commits found, inform user there's nothing to summarize
- Suggest adding `BRANCH-SUMMARY-*.md` to `.gitignore` if not already there
- Link to related task context files in `thoughts/tasks/` if they exist
