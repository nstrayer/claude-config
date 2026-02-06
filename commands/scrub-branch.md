---
description: Scan branch diff for accidental commits (dead code, whitespace, debug artifacts) and fix them
arguments:
  - name: base
    description: Base branch to diff against (default: origin/main)
    required: false
---

# Scrub Branch for Accidental Commits

Review all changes on the current branch compared to the base branch and find unintentional artifacts that shouldn't be shipped.

## Base branch

Use `$ARGUMENTS.base` if provided, otherwise default to `origin/main`.

## Process

### Step 1: Gather the diff

Run these commands in parallel:
- `git diff <base>...HEAD --stat` -- file-level summary
- `git diff <base>...HEAD` -- full diff (read from persisted output if large)
- `git log <base>...HEAD --oneline` -- commits on this branch

### Step 2: Scan for issues

Read through the entire diff carefully. Flag any of the following:

**Dead code:**
- Unused imports (added but never referenced)
- Dead functions/methods (defined but never called)
- Commented-out code blocks
- Leftover debug code (`console.log`, `print()`, `debugger`, etc.)

**Whitespace / formatting noise:**
- Blank line additions or removals unrelated to the feature (e.g., double blank -> single or vice versa)
- Trailing whitespace on added lines
- Indentation-only changes in otherwise untouched code

**Accidental file changes:**
- `.vscode/settings.json` (Peacock colors, personal prefs)
- `.env`, credentials, or secret files
- Unrelated config or lockfile changes
- Files that appear in the diff but have no meaningful feature change

**Stale artifacts:**
- TODO/FIXME/HACK/XXX comments in new code
- Placeholder values or hardcoded test data left in production code

**Incidental cleanups mixed with feature work:**
- `any` -> `unknown` type changes in unrelated code
- Variable renames in untouched functions
- Reformatting of lines not otherwise modified

### Step 3: Report findings

Present a structured report:

```
## Branch Scrub Report

### Issues Found

**1. [Category]: [Brief description]**
- File: `path/to/file.ts` (line N)
- Detail: [What's wrong and why it shouldn't be shipped]

**2. ...**

### Clean
- [List anything checked that looked fine]

### Summary
- Issues found: N
- Files affected: N
```

If no issues are found, say so clearly.

### Step 4: Ask whether to fix

Use AskUserQuestion to ask:
- Question: "Found N issues. Should I fix them?"
- Options: "Fix all" / "Let me review the report first"

### Step 5: Apply fixes

If the user approves:
- Make all fixes (remove dead code, revert whitespace, etc.)
- Do NOT commit automatically -- just leave the working tree dirty so the user can review with `git diff`
- Summarize what was changed

## Important

- Only flag things that are clearly unintentional. Legitimate blank line changes as part of a refactor are fine.
- When reverting whitespace, match exactly what the base branch has.
- Do not touch files that aren't in the branch diff.
- Be conservative: when in doubt, flag it but don't auto-fix.
