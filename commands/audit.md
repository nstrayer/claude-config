---
description: Surface project issues that caused friction in this session
argument-hint: Optional focus (e.g., "testing", "structure", "patterns")
---

# Audit This Session

You are analyzing this coding session to identify **project-level issues** that caused friction. Unlike `/reflect` (which improves Claude configuration), you surface improvements to the codebase itself.

## Focus Area

**User's focus:** $ARGUMENTS

- **If focus is provided**: Weight analysis toward that dimension
- **If empty**: Analyze all dimensions equally

## Important: Scope

- This analyzes friction from the **current session only**
- Findings must be grounded in real problems encountered, not theoretical issues
- If the session was smooth with no friction, say so - don't manufacture findings
- This is NOT a generic linter or static analysis tool

## Framing

Focus on **project improvements**, not workarounds:
- "This module's implicit initialization causes bugs" (project issue)
- "Add CLAUDE.md entry about implicit initialization" (workaround - belongs in /reflect)

Ask: "What about the codebase made this harder than it needed to be?"

---

## Phase 1: Parallel Investigation

Launch **4 parallel Explore agents** in a single message to analyze the session through different lenses:

### Agent 1: Structural Friction

Analyze where project structure caused problems:
- Files that were hard to locate (unclear organization)
- Unclear ownership boundaries (changes touched unexpected areas)
- Circular or tangled dependencies encountered
- Configuration scattered across multiple files
- Inconsistent directory structure or naming

**Output:** List of structural issues with specific examples from the session

### Agent 2: Pattern Inconsistencies

Identify where inconsistent patterns caused confusion or mistakes:
- Multiple ways to do the same thing (which pattern is correct?)
- Code that doesn't follow the conventions of surrounding code
- Implicit behavior that wasn't obvious from reading the code
- Magic values, hidden state, or non-obvious side effects
- Naming inconsistencies that caused misunderstanding

**Output:** List of pattern issues with before/after examples where applicable

### Agent 3: Verification Gaps

Identify where missing verification capability caused friction:
- Changes that couldn't be tested (no tests exist)
- Tests that didn't catch issues they should have
- Missing type definitions that allowed errors
- No way to validate behavior without manual testing
- Integration points with no contract verification

**Output:** List of verification gaps with severity:
- **High**: Caused bugs or required significant manual verification
- **Medium**: Made confidence in changes lower
- **Low**: Minor inconvenience

### Agent 4: Knowledge Gaps

Identify where missing documentation or context caused friction:
- Behavior that had to be reverse-engineered from code
- Non-obvious decisions with no recorded rationale
- Tribal knowledge required that wasn't documented
- APIs or interfaces with unclear contracts
- Error messages that didn't help diagnose problems

**Output:** List of knowledge gaps with what information was missing

---

## Phase 2: Synthesize Findings

After all agents complete, filter and organize findings.

### Filter Criteria

Only include findings that meet these criteria:

| Include | Exclude |
|---------|---------|
| Caused real friction this session | Theoretical "could be better" |
| Actionable improvement exists | Vague concerns |
| Would prevent future similar issues | One-time flukes |
| Project-level fix possible | Requires external changes |

### Severity Assessment

Rate each finding:
- **High**: Caused significant delay, bugs, or rework
- **Medium**: Caused confusion or extra investigation
- **Low**: Minor friction, easily worked around

### Report Structure

```
## Session Audit

### Summary
[1-2 sentences: What was the main source of friction?]

### Findings

#### High Severity
| Issue | Area | Impact | Suggested Fix |
|-------|------|--------|---------------|
| [Specific issue] | [File/module] | [What went wrong] | [Concrete improvement] |

#### Medium Severity
| Issue | Area | Impact | Suggested Fix |
|-------|------|--------|---------------|

#### Low Severity
| Issue | Area | Impact | Suggested Fix |
|-------|------|--------|---------------|
```

**If no findings in a severity level:** Skip that section entirely.

**If no findings at all:**
> "This session went smoothly - no significant project friction identified. The areas touched appear well-structured and maintainable."

---

## Phase 3: Prioritize with User

Present the synthesized findings, then use `AskUserQuestion`:

```yaml
question: "Which findings should I expand into detailed recommendations?"
header: "Priority"
options:
  - label: "High severity only"
    description: "Focus on the biggest issues"
  - label: "All findings"
    description: "Get recommendations for everything"
  - label: "Pick specific items"
    description: "I'll tell you which ones"
  - label: "None - just wanted the analysis"
    description: "Keep the report, skip recommendations"
metadata:
  source: "audit"
```

---

## Phase 4: Generate Recommendations

For each selected finding, generate a detailed recommendation.

### Recommendation Quality

Each recommendation must be:
- **Specific**: Exact files/functions/patterns to change
- **Actionable**: Clear steps to implement
- **Proportional**: Fix matches the severity of the problem
- **Scoped**: Doesn't balloon into a massive refactor

### Recommendation Format

```markdown
### [Finding Title]

**Problem:** [What went wrong and why]

**Location:** [Specific files/modules affected]

**Recommendation:**
[Concrete steps to fix, with examples if helpful]

**Effort:** Low / Medium / High
[Brief justification]

**Prevention:**
[How this fix prevents similar issues elsewhere]
```

### Avoid Over-Engineering

Recommendations should fix the problem, not redesign the system:
- Missing test → Add test for this behavior
- Implicit behavior → Add explicit initialization or documentation
- Inconsistent pattern → Align with dominant pattern OR document when to use each
- Scattered config → Consolidate OR add clear cross-references

Do NOT suggest:
- Wholesale rewrites when targeted fixes suffice
- New abstractions for one-time issues
- Framework changes for local problems

---

## Phase 5: Create Action Items (Optional)

If user wants to act on recommendations, use `AskUserQuestion`:

```yaml
question: "How should I capture these recommendations?"
header: "Output"
options:
  - label: "Add to todo list"
    description: "Create todos for implementation"
  - label: "Create GitHub issues"
    description: "File issues for each recommendation (requires gh CLI)"
  - label: "Just the report"
    description: "Keep recommendations as reference only"
metadata:
  source: "audit"
```

**If todo list:** Use TodoWrite to create actionable items.

**If GitHub issues:** Use `gh issue create` for each recommendation with appropriate labels.

---

## Output: Final Summary

```
## Audit Complete

### Session Friction Summary
[1-2 sentences on what made this session harder than needed]

### Key Findings
1. [Most impactful issue and its fix]
2. [Second most impactful]
3. [Third if applicable]

### Recommendations Generated
- [N] high severity
- [N] medium severity
- [N] low severity

### Next Steps
[What was done with recommendations - todos created, issues filed, or kept as reference]
```

---

## Differentiation from /reflect

| Aspect | /reflect | /audit |
|--------|----------|--------|
| **Surfaces** | Missing Claude context | Project issues |
| **Output** | CLAUDE.md entries, settings | Improvement recommendations |
| **Fixes** | How Claude works | How the codebase works |
| **Action** | Config changes (immediate) | Implementation work (future) |
| **Framing** | "What should Claude know?" | "What made this hard?" |

**Use /reflect when:** You want Claude to remember something for next time.

**Use /audit when:** You want to fix the underlying project issue.

**Use both when:** A session had friction - /reflect captures the workaround, /audit captures the fix.

---

## Edge Cases

### Very Short Session
If fewer than 3 substantive exchanges:
> "This session was brief. Run /audit after longer working sessions where you encountered friction."

### Only CLAUDE.md Issues Found
If all friction was missing context, not project issues:
> "The friction in this session was mainly missing context, not project structure. Consider running /reflect instead to capture those learnings."

### Too Many Findings
If more than 8 findings:
- Group by area (structure, patterns, testing, documentation)
- Present top 3 per category
- Offer to dive deeper into specific areas
