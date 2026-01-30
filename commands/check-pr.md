---
description: Review PR changes for over-engineering and duplication before submission
---

# Check PR for Simplification Opportunities

Review the current changes to catch over-engineering before PR submission.

## Process

### Step 1: Understand Intent

First, ask what this PR is supposed to accomplish using the AskUserQuestion tool:
- Question: "What is this PR supposed to accomplish? (Brief description)"
- Header: "PR Intent"
- Let them describe in their own words (use options that cover common cases plus free-form)

This context helps judge if the implementation is proportional to the goal.

### Step 2: Gather Changes

Run these commands to understand what changed:
- `git diff --stat HEAD` - see files changed and line counts
- `git diff HEAD` - see actual changes

Identify:
- Files with significant additions (50+ lines)
- New files that were created
- Functions/components that were added

### Step 3: Parallel Codebase Analysis

Launch up to 3 Explore agents in a SINGLE message to search the codebase efficiently:

**Agent 1 - Similar Code Search:**
Search for components, functions, or utilities with similar names or purposes to the new code. Look for existing implementations that do similar things.

**Agent 2 - Import Analysis:**
For any new files created, count how many times each is imported elsewhere in the codebase. Flag any new file with only 1 import as potential over-abstraction.

**Agent 3 - Pattern Matching:**
Find existing patterns in the codebase that accomplish similar goals. Look for reusable utilities, base components, or established approaches that could have been extended.

### Step 4: Analyze Findings

For each significant change, evaluate:

- **Import count**: Is a new file imported only once? → Likely over-abstraction, could be inlined
- **Similar code exists**: Found a similar component/function? → Potential duplication, could extend existing
- **Prop/parameter overlap**: New component shares many props with existing one? → Could add a prop to existing instead
- **Proportionality**: Does the change size match the stated intent? A bug fix shouldn't need 300 new lines.
- **Name similarity**: New `UserCard` when `Card` exists? → Probably should extend `Card`

### Step 5: Report Findings

Output a structured report:

```
## PR Simplification Report

### Intent
[What the user said this PR accomplishes]

### Findings

**1. [filename.tsx]** (+N lines)
- Concern: [what looks over-engineered]
- Evidence: [similar code at path, import count, prop overlap]
- Suggestion: [concrete simplification approach]

**2. [another-file.ts]** (+N lines)
- Concern: ...
- Evidence: ...
- Suggestion: ...

### Summary
- Files flagged: N
- Estimated reduction: ~X lines → ~Y lines

OR if clean:

### Summary
No over-engineering detected. Changes look appropriately scoped for the stated intent.
- Files reviewed: N
- Total lines added: X
```

## Anti-Patterns to Flag

| Pattern | What to Look For |
|---------|-----------------|
| Duplicated component | Similar component name exists, shares 70%+ props |
| Reimplemented utility | Function name or purpose matches existing utility |
| Over-abstraction | New file/hook/helper imported only once |
| Unnecessary new file | Existing file already handles this domain |
| Verbose implementation | Similar task done elsewhere with fewer lines |
| Premature generalization | Config/options added but only one value ever used |

## Key Questions to Answer

For each significant addition, ask:
1. Does similar functionality already exist in this codebase?
2. Could we extend an existing component/function instead of creating new?
3. Is this new abstraction used more than once? If not, inline it.
4. Is the change proportional to the stated intent?
5. Are we adding options/configuration that aren't actually needed yet?

## Important

- Report findings only - do not make changes
- Be specific: cite file paths and line counts
- Provide actionable suggestions, not just criticism
- If the PR looks clean, say so clearly
