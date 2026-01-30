---
description: Analyze the session to surface learnings and improve your Claude setup
argument-hint: Optional focus (e.g., "workflow", "tools", "mistakes")
---

# Reflect on This Session

You are performing a deep, multi-dimensional analysis of this coding session to identify learnings and improvements. Unlike `/remember` (which captures a single learning), you analyze the entire session across multiple categories.

## Focus Area

**User's focus:** $ARGUMENTS

- **If focus is provided**: Weight your analysis toward that dimension
- **If empty**: Analyze all dimensions equally

## Important: Scope

- This is an analysis and recommendation phase
- Do NOT make changes without explicit user approval
- Present findings clearly before asking about implementation
- If the session was very brief (< 3 substantive exchanges), suggest `/remember` for specific items instead

## Framing: Blameless Analysis

All analysis should be framed as **systemic improvements**, not blame:
- ✓ "CLAUDE.md could benefit from documenting X"
- ✓ "Session would have been smoother with context about Y"
- ✗ "Claude made a mistake by doing Z"
- ✗ "User should have specified W"

Assume all parties acted reasonably given available information. Focus on **what context was missing**, not who was at fault.

---

## Phase 1: Parallel Investigation

Launch **4 parallel Explore agents** in a single message to analyze different dimensions of the conversation:

### Agent 1: Technical Discoveries

Analyze the conversation for technical learnings:
- Commands, tools, or APIs discovered during the session
- Patterns or conventions found in the codebase
- Non-obvious behaviors or quirks encountered
- Useful shortcuts or techniques that worked well
- Environment setup or configuration details learned

**Output:** List of technical discoveries with brief descriptions

### Agent 2: Workflow Friction

Identify what slowed things down or caused problems:
- Repeated attempts at the same task (indicates missing context)
- Corrections the user had to make (indicates wrong assumptions)
- Missing information that required extra investigation
- Tools or permissions that were needed but unavailable
- Misunderstandings between user and assistant
- Back-and-forth clarifications that could have been avoided

Also identify **validation gaps** (ground truth missing):
- Outputs that weren't verified (tests not run, results not checked)
- Assumptions made without confirmation
- Where feedback loops were missing

**Output:** List of friction points with severity rating:
- **High**: Caused significant delay or required major correction
- **Medium**: Caused minor delay or small correction
- **Low**: Minor inconvenience, easily resolved

### Agent 3: Configuration Gaps

Compare session needs against current configuration:

1. Read `~/.claude/CLAUDE.md` (global instructions)
2. Read project `CLAUDE.md` if it exists
3. Check `~/.claude/settings.json` and `~/.claude/settings.local.json`
4. Review available commands in `~/.claude/commands/`

Identify:
- Context that would have helped but wasn't documented
- Permissions that were requested during the session
- Commands that could have simplified repeated tasks
- Project-specific patterns that should be documented
- MCP servers or tools that were needed

**Output:** List of configuration gaps with proposed solutions

### Agent 4: What Went Well

Identify effective patterns worth reinforcing:
- Approaches that worked smoothly without correction
- Tools or techniques that saved time
- Communication patterns that prevented confusion
- Workflows that should become standard practice
- Moments where existing CLAUDE.md guidance helped

**Output:** List of positive patterns to potentially reinforce or document in CLAUDE.md

---

## Phase 2: Synthesize Findings

After all agents complete, organize findings into a structured report.

### Filter: Patterns vs Incidents

Before including a finding, assess:

| Type | Criteria | Action |
|------|----------|--------|
| **Pattern** | Appeared 2+ times OR significant impact | Include in report |
| **Incident** | One-time, easily resolved | Note but deprioritize |
| **Documented** | Already in CLAUDE.md | Skip entirely |

Focus on patterns worth codifying, not every small hiccup.

### Report Structure

```
## Session Analysis

### What Went Well
- [Effective pattern]: [Why it worked and whether to reinforce]

### Technical Discoveries
- [Discovery]: [Brief description and why it's useful to remember]

### Friction Points
| Issue | Severity | Root Cause | Prevention |
|-------|----------|------------|------------|
| [Issue description] | High/Med/Low | [What context was missing] | [How to prevent] |

### Configuration Gaps
**Missing from CLAUDE.md:**
- [Item that should be documented]

**Permissions/Tools:**
- [Permission or MCP that was needed]

**Command Opportunities:**
- [Repeated workflow that could be a command]
```

**If no findings in a category:** Skip that section entirely rather than showing empty results.

---

## Phase 3: Prioritize with User

Present the synthesized findings, then use `AskUserQuestion` to determine what to act on:

```yaml
question: "Which areas should I focus on for improvements?"
header: "Priority"
options:
  - label: "All findings"
    description: "Process everything identified"
  - label: "High-severity only"
    description: "Focus on the biggest friction points"
  - label: "Configuration changes"
    description: "Just CLAUDE.md and settings updates"
  - label: "Pick specific items"
    description: "I'll tell you which findings to act on"
metadata:
  source: "reflect"
```

**If user selects "Pick specific items":** Present numbered list of findings and ask which to include.

---

## Phase 4: Scope Determination

For each actionable finding, determine where it belongs:

### Infer Automatically When Clear

**Project-specific signals** → Project CLAUDE.md:
- File paths, directory names specific to this repo
- Project commands (`pnpm`, `cargo`, specific scripts)
- Architecture decisions for this codebase
- Dependencies or tooling specific to this project

**Global signals** → `~/.claude/CLAUDE.md`:
- Personal preferences (coding style, communication)
- General patterns that apply everywhere
- Universal behaviors you want Claude to follow
- Tool preferences not tied to a project

### Only Ask When Genuinely Ambiguous

```yaml
question: "Where should this apply?"
header: "Scope"
options:
  - label: "This project only"
    description: "Add to project CLAUDE.md"
  - label: "All projects"
    description: "Add to ~/.claude/CLAUDE.md"
  - label: "Skip this one"
    description: "Don't persist this finding"
metadata:
  source: "reflect"
```

---

## Phase 5: Generate Recommendations

For each approved finding, generate specific recommendations.

### Rule Quality Checklist

Before proposing a CLAUDE.md entry, verify it passes these criteria:

- [ ] **Atomic**: One behavior per rule (split compound rules)
- [ ] **Precise**: Clear when this applies (not vague)
- [ ] **Justified**: Includes WHY (the problem it solves)
- [ ] **Testable**: Would have changed this session's outcome
- [ ] **Intern test**: Enough context for anyone to follow

**Example of good rule:**
```diff
+ - Run `pnpm test:unit` before commits (CI requires passing tests)
```
↑ Atomic, precise trigger, explains why

**Example of bad rule:**
```diff
+ - Write good code and follow best practices
```
↑ Vague, not actionable, no clear trigger

### CLAUDE.md Changes

Show exact text to add using diff format:

```markdown
### Update: [target file path]

**Why:** [Brief explanation of how this helps future sessions]

```diff
## [Section Name]
+ - [New entry in imperative mood]
+ - [Another entry if applicable]
```
```

**Style guidelines:**
- Imperative mood: "Use early returns" not "You should use early returns"
- Concise: One line per concept
- No fluff: Skip "Remember to..." or "Always..."
- Match existing style of target file

**Include concrete examples when helpful:**
- Reference specific session moments that illustrate the pattern
- Show before/after if proposing a code style rule
- Link the rule to the problem it would have prevented

### Settings Changes

If permissions or MCP servers are needed:

```json
// Suggested addition to ~/.claude/settings.json
{
  "permissions": {
    "allow": ["Bash(npm run *)"]
  }
}
```

### Command Suggestions

If a workflow was repeated multiple times:

```markdown
### Suggested Command: /[name]

**Purpose:** [What it would do]
**Trigger:** [When you found yourself doing this repeatedly]

Consider creating `~/.claude/commands/[name].md` for this workflow.
```

---

## Phase 6: Execute with Approval

Present all proposed changes as a batch:

```
## Proposed Changes

### CLAUDE.md Updates
- **~/.claude/CLAUDE.md**: [N] new entries
- **./CLAUDE.md**: [M] new entries

### Settings
- [Permission/MCP changes if any]

### Commands
- [Suggested new commands if any]
```

Then confirm with the user:

```yaml
question: "Apply these changes?"
header: "Confirm"
options:
  - label: "Apply all"
    description: "[N] total changes across [M] files"
  - label: "One by one"
    description: "Confirm each change individually"
  - label: "Show full diff"
    description: "See exactly what will change before deciding"
  - label: "Cancel"
    description: "Don't make any changes"
metadata:
  source: "reflect"
```

**On approval:**
- Execute changes using Edit tool
- Show summary of what was updated

---

## Output: Final Summary

After execution (or if no changes needed):

```
## Reflection Complete

### What Worked Well
- [Positive pattern identified and reinforced]

### Changes Applied
- **~/.claude/CLAUDE.md**: [Description of additions]
- **./CLAUDE.md**: [Description of additions]
- **Settings**: [Changes made or "No changes"]

### Key Learnings (Top 3)
1. [Most impactful finding]
2. [Second most impactful]
3. [Third most impactful]

### For Future Sessions
- [Any actionable insight not captured in config files]
```

---

## Edge Cases

### Very Short Session
If the conversation has fewer than 3 substantive exchanges:
> "This session was brief. For capturing specific learnings, try `/remember [what to remember]` instead. Run `/reflect` after longer sessions for holistic analysis."

### No Friction Found
If analysis reveals no friction or gaps:
> "This session went smoothly! Here's what worked well: [list positive patterns]. No configuration changes needed, but consider documenting these effective patterns for future reference."

### Too Many Findings
If more than 10 actionable findings:
- Group by category
- Suggest processing in batches
- Prioritize high-severity items first

### Conflicting with Existing Config
If a finding conflicts with existing CLAUDE.md content:
- Flag the conflict
- Ask user whether to update, skip, or merge

---

## Differentiation from /remember

| Aspect | /remember | /reflect |
|--------|-----------|----------|
| **Scope** | Single learning | Entire session |
| **Trigger** | User identifies specific item | User requests analysis |
| **Categories** | One item at a time | Multiple dimensions |
| **Output** | One CLAUDE.md entry | Structured report + batch changes |
| **Interaction** | Scope + confirm | Prioritization + batch approval |
| **Best for** | "Remember that I prefer X" | "What should I learn from this?" |

**When to suggest /remember instead:** User asks to capture a specific, single item they already know.

**When /reflect is appropriate:** End of session review, "improve my setup", "what did we learn", holistic analysis request.
