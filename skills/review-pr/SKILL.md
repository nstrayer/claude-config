---
name: review-pr
description: Get acquainted with a PR - checkout and generate a summary document
---

# Review PR: Get Acquainted Before Diving In

Help the user get oriented with a PR before detailed review. Handle git state, checkout the PR, and generate a summary document.

## Phase 1: Parse Input & Get PR Info

### Handle Missing Argument

If no argument `$ARGUMENTS` is provided, ask the user:

```
Question: "Which PR would you like to review?"
Header: "PR"
Options:
- "Enter PR number" (let them type a number)
- "Enter PR URL" (let them paste a URL)
```

### Extract PR Number

- If argument looks like a URL (`https://...`), extract the PR number from the path
- If argument is just a number, use it directly
- Store as `PR_NUMBER` for subsequent commands

### Fetch PR Metadata

Run: `gh pr view <PR_NUMBER> --json number,title,author,body,headRefName,baseRefName,url,additions,deletions,changedFiles,isDraft,reviews,reviewRequests,statusCheckRollup,closingIssuesReferences`

If this fails (invalid PR, not in a repo, etc.):
- Show the error clearly
- Offer to retry with a different PR number

Store the JSON response for later use.

### Fetch Size Comparison Data

Run: `gh pr list --state merged --limit 20 --json additions,deletions`

Calculate the median additions and deletions from recent merged PRs. This will be used to provide context for the PR size.

## Phase 2: Check Git State

Run these commands to understand current state:

1. `git branch --show-current` - Get current branch name
2. `git status --porcelain` - Check for uncommitted changes (empty = clean)
3. `git stash list` - Check if there are stashed changes

Determine the state:
- **Current branch**: Is it the base branch (usually `main` or `master`) or the PR branch or something else?
- **Working directory**: Clean (no output from porcelain) or dirty (has output)?

## Phase 3: Handle Git State (Interactive)

Based on the state detected, present options via `AskUserQuestion`:

### State: On base branch, clean working directory
- Auto-proceed to checkout (no question needed)

### State: On base branch, dirty working directory
```
Question: "You have uncommitted changes. How should I handle them?"
Header: "Git state"
Options:
- "Stash changes and checkout PR" - I'll stash your changes, checkout the PR, and you can unstash later
- "Create a worktree" - I'll create a separate worktree at ../repo-pr-<number> for isolated review
```

### State: On different branch, clean working directory
```
Question: "You're on branch '<branch>'. How should I proceed?"
Header: "Git state"
Options:
- "Checkout PR branch here" - Switch to the PR branch in this worktree
- "Create a worktree" - I'll create a separate worktree at ../repo-pr-<number> for isolated review
```

### State: On different branch, dirty working directory
```
Question: "You're on branch '<branch>' with uncommitted changes. How should I proceed?"
Header: "Git state"
Options:
- "Stash and checkout PR" - I'll stash your changes, checkout the PR, and you can unstash later
- "Create a worktree" - I'll create a separate worktree at ../repo-pr-<number> for isolated review
- "Abort" - Cancel this review, I'll handle my changes first
```

### State: Already on the PR branch
- Skip checkout entirely, proceed to summary generation
- Inform the user: "You're already on the PR branch. Generating summary..."

## Phase 4: Execute Git Operations

Based on user choice:

### Option: Stash and checkout
1. `git stash push -m "Pre-review stash for PR #<number>"`
2. `gh pr checkout <PR_NUMBER>`
3. Inform user they can run `git stash pop` when done

### Option: Create worktree
1. Determine worktree path: `../<repo-name>-pr-<number>`
2. Check if worktree already exists at that path
   - If exists, ask: "Worktree already exists. Use existing or recreate?"
3. `git worktree add <path> -b pr-<number>-review`
4. `cd <path> && gh pr checkout <PR_NUMBER>`
5. Display worktree location and instructions:
   ```
   Worktree created at: ../<repo-name>-pr-<number>

   To switch to the worktree:
     cd ../<repo-name>-pr-<number>
   ```

### Option: Direct checkout
1. `gh pr checkout <PR_NUMBER>`

## Phase 5: Generate PR Summary Document

### Get Additional Data

Run: `gh pr diff <PR_NUMBER>` to get the full diff for analysis

### Analyze Changes

Group the changed files by area:
- **API**: Files in `api/`, `routes/`, `controllers/`, endpoints, handlers
- **UI**: Components, views, pages, stylesheets
- **Data**: Models, schemas, migrations, database-related
- **Tests**: Test files (`*.test.*`, `*.spec.*`, `__tests__/`)
- **Config**: Configuration files, environment, build configs
- **Docs**: Documentation, README updates
- **Other**: Anything that doesn't fit above categories

Only include categories that have changes.

### Summarize Commits

Run: `gh pr view <PR_NUMBER> --json commits` to get commit messages

Summarize the commit messages to explain the intent and motivation behind the changes.

### Summarize CI Status

From the `statusCheckRollup` data, count:
- How many checks passed
- How many checks failed
- How many checks are pending

Format as: "X passing, Y failing, Z pending" or "X/Y passing" if all complete

### Summarize Reviews

From the `reviews` and `reviewRequests` data:
- List who approved
- List who requested changes
- List who is awaiting review (from reviewRequests)

### Create the Summary File

Create file at project root: `PR-REVIEW-<number>.md`

```markdown
# PR #<number>: <title>

**Author**: @<author login>
**Branch**: <headRefName> -> <baseRefName>
**URL**: <url>
<If isDraft is true, include: **Status**: Draft>
**Stats**: +<additions> -<deletions> across <changedFiles> files <(comparison to median, e.g., "larger than typical: median is +45 -20")>

---

## Checks & Reviews

**CI Status**: <X passing, Y failing, Z pending - or "No checks configured" if empty>
**Reviews**: <who approved, who requested changes - or "No reviews yet" if empty>
**Awaiting**: <reviewRequests who haven't reviewed - or omit line if empty>

---

## Closes

<List linked issues from closingIssuesReferences with format "#123: Issue title", or "No linked issues" if empty>

---

## Description (from PR)

<body from PR, or "No description provided" if empty>

---

## What Changed

<High-level summary grouped by area - only include areas with changes>

- **API**: <changes to API layer>
- **UI**: <changes to UI components>
- **Data**: <changes to data models/DB>
- **Tests**: <test additions/modifications>
- **Config**: <configuration changes>

---

## Why (from commits)

<Commit messages summarized to explain intent and motivation>

---

## Files Changed

<details>
<summary>View all <changedFiles> files</summary>

- `path/to/file1.ts`
- `path/to/file2.ts`
- ...

</details>

---

## Review Notes

_Space for your notes as you review..._

- [ ] Checked code quality
- [ ] Verified tests pass
- [ ] No security concerns
- [ ] Ready to approve

```

### Check .gitignore

After creating the file, check if `PR-REVIEW-*.md` is in `.gitignore`:

1. `grep "PR-REVIEW" .gitignore` (if .gitignore exists)
2. If not found, suggest: "Consider adding `PR-REVIEW-*.md` to your .gitignore to keep these review files local."

## Phase 6: Present Summary

Display a brief summary of what was done:

```
Created PR-REVIEW-<number>.md with summary of PR #<number>: "<title>"

You're now on branch: <branch>
<If worktree: "Worktree created at: <path>\n\nTo switch to the worktree:\n  cd <path>">
<If stashed: "Your previous changes are stashed - run `git stash pop` when done">
```

The user can now explore the PR on their own or ask follow-up questions naturally.

## Edge Cases

1. **Not in a git repository**: Error with "This command must be run from within a git repository."

2. **gh CLI not available**: Error with "This command requires the GitHub CLI (gh). Install it from https://cli.github.com/"

3. **Not authenticated with gh**: The `gh pr view` command will fail - suggest `gh auth login`

4. **PR doesn't exist**: Show the error from gh and offer to retry

5. **Network issues**: Show the error and suggest checking connection

## Important Notes

- This command is for getting acquainted with a PR, not for approving or merging
- The generated summary file is for the reviewer's personal notes
- Always let the user choose how to handle their git state - don't make assumptions
- Keep the summary concise but comprehensive