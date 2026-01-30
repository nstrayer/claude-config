---
description: Review recent work for duplication, over-engineering, and simplification opportunities
argument-hint: Optional file/directory path or "recent" for recently modified files
---

# Cleanup Review

Review recent implementation work for opportunities to simplify, consolidate, and reuse existing code.

## Focus Area

**User's target:** $ARGUMENTS

---

## Phase 1: Scope Identification

Determine what files to analyze based on input.

### If argument provided:
- Use the specified path directly
- If path is a directory, analyze all source files within
- If path is a file, analyze that file and related imports

### If no argument:
1. **Primary**: Look for files touched in the current conversation
   - Scan conversation for files that were edited or created
   - These are the most relevant for cleanup review

2. **Fallback**: If no files touched in conversation
   - Run `git diff --name-only main...HEAD 2>/dev/null || git diff --name-only master...HEAD`
   - Review files changed on current branch

3. **Last resort**: If not in a git repo or no changes
   - Ask user to specify a path

### Scope Confirmation

Before deep analysis, show the user:
```
## Scope
Reviewing: [list of files/directories]
Total files: N
```

Then use AskUserQuestion:
```yaml
question: "Should I analyze this scope, or would you like to adjust it?"
header: "Scope"
options:
  - label: "Analyze this scope"
    description: "Proceed with the files listed above"
  - label: "Narrow scope"
    description: "I'll specify particular files/directories"
  - label: "Expand scope"
    description: "Include additional areas"
```

---

## Phase 2: Parallel Investigation

Launch **3 Explore agents in a single message** to analyze the scoped files. Pass each agent the explicit file list from Phase 1.

### Agent 1: Duplication Hunter

**Prompt template:**
```
Analyze these files for duplicated code: [FILE_LIST]

Search for:
1. **Identical blocks**: 5+ consecutive lines that appear in multiple places
2. **Near-duplicates**: Functions/methods where 80%+ of lines match (same logic, different variable names)
3. **Repeated patterns**: Same sequence of operations (e.g., fetch → validate → transform → store) in 2+ places
4. **Copy-paste signatures**: Functions with identical parameter lists doing similar work

Detection strategies:
- Compare function bodies by structure, ignoring variable names
- Look for identical error handling blocks
- Find repeated conditional chains (same if/else structure)

**Ignore (not duplication):**
- Test fixtures and test data setup
- Interface implementations that must match a contract
- Boilerplate required by frameworks (e.g., Redux reducers)
- Generated code

**Output format:**
For each finding:
- Location A: file:line
- Location B: file:line
- Similarity: percentage or "identical"
- Shared logic: one-sentence description
```

### Agent 2: Complexity Analyzer

**Prompt template:**
```
Analyze these files for unnecessary complexity: [FILE_LIST]

Search for:
1. **Single-use abstractions**: Files that export functions/classes imported by exactly 1 other file
   - Use grep to count imports: `import.*from ['"]./path['"]`
   - Flag if count = 1 and the abstraction isn't a clear domain concept

2. **Wrapper functions adding no value**: Functions that just forward to another function
   - Body is single return/call statement
   - No transformation, validation, or error handling added

3. **Over-parameterized code**:
   - Config objects where only 1 value is ever passed
   - Boolean parameters that are always true or always false at call sites
   - Options with defaults that are never overridden

4. **Deep nesting**:
   - 4+ levels of indentation (excluding class/function declaration)
   - Callbacks nested 3+ deep

5. **Premature abstraction**:
   - Generic solution built for a single concrete use case
   - "Plugin" or "strategy" patterns with only one implementation

**Ignore:**
- Dependency injection patterns (single-use is intentional)
- Public API boundaries (abstraction serves documentation)
- Type definitions and interfaces

**Output format:**
For each finding:
- Location: file:line
- Issue type: [single-use | wrapper | over-parameterized | deep-nesting | premature-abstraction]
- Evidence: usage count, nesting depth, or specific observation
- Current callers/importers: list
```

### Agent 3: Reuse Opportunities

**Prompt template:**
```
Analyze these files for missed reuse opportunities: [FILE_LIST]

Search for:
1. **Reimplemented stdlib**: Custom code that duplicates language/framework builtins
   - Array manipulation that could use map/filter/reduce
   - String operations that exist in standard library
   - Date handling that a library already provides

2. **Existing utilities ignored**:
   - Search codebase for `utils/`, `helpers/`, `lib/`, `common/` directories
   - Compare new code against existing utilities by function signature and purpose
   - Flag when similar utility exists but wasn't used

3. **Patterns used elsewhere**:
   - Find how similar problems are solved in other parts of the codebase
   - Look for base classes/components that could be extended
   - Check for existing HOCs, hooks, or decorators that apply

**Detection approach:**
- First, catalog existing utilities: glob for common utility locations
- Then compare new implementations against the catalog
- Search for similar function names across codebase

**Ignore:**
- Intentional reimplementation (e.g., for performance, to avoid dependency)
- Test utilities (isolation is often preferred)

**Output format:**
For each finding:
- New code: file:line, brief description
- Existing alternative: file:line or library function name
- Similarity: what they share
- Recommendation: use existing, extend existing, or consolidate both
```

---

## Phase 3: Synthesize Findings

After agents complete, categorize findings by severity.

### Severity Definitions

| Severity | Criteria | Examples |
|----------|----------|----------|
| **High** | Identical/near-duplicate code (80%+) in 2+ places; OR single-use abstraction in its own file with exactly 1 importer | Two 20-line functions doing the same validation; a `useFormHelper.ts` imported only by `LoginForm.tsx` |
| **Medium** | Reimplemented stdlib/utility; over-parameterized functions; unnecessary wrappers | Custom `isEmpty()` when lodash is available; config object where all call sites pass identical values |
| **Low** | Deep nesting that could flatten; minor consolidation opportunities | 4-level nested callbacks; two 3-line blocks that could share a helper |

### Anti-Patterns to Flag

| Pattern | Detection | Threshold |
|---------|-----------|-----------|
| Duplicate logic | Same algorithm in 2+ places | 5+ identical lines or 80%+ similar function bodies |
| Single-use abstraction | Helper/hook/util imported only once | Exactly 1 importer AND not a domain concept |
| Reimplemented utility | Existing utility function does same thing | Match in `utils/`, `lib/`, or stdlib |
| Over-parameterized | Config options where only one value is used | 0 call sites override the default |
| Unnecessary wrapper | Thin wrapper adding no value | Single-statement body, no transformation |
| Copy-paste with tweaks | Near-duplicate code blocks | 80%+ line similarity, different variable names |
| Premature generalization | Abstraction built for hypothetical future needs | Generic pattern with exactly 1 concrete implementation |

### Initial Report

```markdown
## Cleanup Report

### Scope
[Files/area reviewed]

### Findings

#### High Priority
| Location | Issue | Evidence |
|----------|-------|----------|
| path/file.ts:45 | [Issue type] | [What was found] |

#### Medium Priority
| Location | Issue | Evidence |
|----------|-------|----------|

#### Low Priority
| Location | Issue | Evidence |
|----------|-------|----------|

### Summary
- Files reviewed: N
- High priority issues: X
- Medium priority issues: Y
- Low priority issues: Z
```

**If no findings:**
> "No cleanup opportunities identified. The reviewed code appears well-structured with appropriate reuse of existing patterns."

---

## Phase 4: User Checkpoint

Present findings summary, then use AskUserQuestion:

```yaml
question: "Which findings should I expand with concrete refactoring suggestions?"
header: "Details"
options:
  - label: "High priority only"
    description: "Focus on the most impactful issues"
  - label: "High and medium"
    description: "Get suggestions for significant issues"
  - label: "All findings"
    description: "See suggestions for everything found"
  - label: "Pick specific items"
    description: "I'll tell you which ones"
metadata:
  source: "cleanup"
```

---

## Phase 5: Recommendations

For selected findings, provide specific refactoring suggestions.

### Recommendation Format

For each finding:

```markdown
### [Location]: [Issue Type]

**Current code:**
```[language]
[relevant snippet]
```

**Issue:** [What's wrong and why it matters]

**Suggestion:** [Specific fix approach]

**After:**
```[language]
[how code would look after cleanup]
```

**Impact:** ~N lines removable
```

### Quality Guidelines

Each recommendation must be:
- **Specific**: Exact code locations and changes
- **Actionable**: Clear steps to implement
- **Safe**: No behavior changes unless explicitly noted
- **Minimal**: Smallest change that addresses the issue

### Avoid Scope Creep

Do NOT suggest:
- Unrelated refactoring in nearby code
- New abstractions to "improve" the fix
- Test additions (that's a different concern)
- Style changes beyond the identified issue

---

## Final Summary

```markdown
## Cleanup Complete

### Scope Reviewed
[Files/directories analyzed]

### Findings Summary
- High priority: N issues
- Medium priority: N issues
- Low priority: N issues

### Recommended Changes
[List of specific refactorings suggested]

### Estimated Impact
- Lines removable: ~N
- Files affected: N

### Next Steps
To implement these suggestions, you can:
1. Review each recommendation above
2. Apply changes incrementally, testing as you go
3. Run /check-pr before committing to verify no over-engineering
```

---

## Differentiation

| Aspect | /cleanup | /check-pr | /audit |
|--------|----------|-----------|--------|
| **Scope** | Recent work / specified area | Staged PR changes | Whole session friction |
| **Focus** | Code quality & reuse | Over-engineering in diff | Project-level issues |
| **Trigger** | After implementation | Before PR submission | After difficult session |
| **Output** | Refactoring suggestions | PR feedback | Project improvements |

**Use /cleanup when:** You've done implementation work and want to consolidate before moving on.

**Use /check-pr when:** You're about to submit a PR and want to catch over-engineering.

**Use /audit when:** A session was frustrating and you want to identify root causes.

---

## Edge Cases

### No files in scope
If scope identification finds nothing:
> "No files identified for review. Please specify a path: `/cleanup src/components`"

### Too many files
If scope exceeds 20 files:
- Show file list
- Ask user to narrow scope or confirm they want full analysis
- Warn that analysis may take longer

### No issues found
If all agents return empty:
> "No cleanup opportunities found. The code in scope appears clean and well-organized."

---

## Important

- **Report only** - do not make changes automatically
- Be specific with file paths and line numbers
- Provide actionable suggestions, not just criticism
- Respect existing code style and patterns
- If code looks clean, say so clearly
