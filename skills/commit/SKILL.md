---
name: commit
description: Create git commits with user approval
---

# Commit Changes

## Process:

1. **Review the changes:** `git status` and `git diff`; decide whether they're one commit or several logical ones.

2. **Plan your commit(s):** group related files; write messages in imperative mood, focused on why not just what.

3. **Present your plan to the user:**
   - List the files you plan to include for each commit/change
   - Show the commit message(s) you'll use
   - Ask: "I plan to create [N] commit(s) with these changes. Shall I proceed?"

4. **Execute upon confirmation:**
   - Use `git add` with specific files (never use `-A` or `.`)
   - Create commits with your planned messages: `git commit -m "message"`
   - Show the result with `git log --oneline -n [number]`

## Important:
- **NEVER add co-author information or Claude attribution** -- no "Generated with Claude", no "Co-Authored-By". Write commit messages as if the user wrote them.
- Keep commits focused and atomic.