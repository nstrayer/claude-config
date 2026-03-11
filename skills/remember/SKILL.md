---
name: remember
description: Intelligently add learnings to CLAUDE.md to avoid repeating mistakes
---

# Remember This

You are tasked with intelligently updating CLAUDE.md to incorporate a new learning, preference, or instruction.

## Step 1: Identify What to Remember

- If the user provided specific text, use that directly
- Otherwise, review the recent conversation to identify: mistakes made, preferences discovered, patterns learned, corrections given
- Be specific about the learning--don't ask the user to clarify vague ideas you should be able to infer

## Step 2: Determine Scope (Smart Inference)

**Infer automatically when clear--don't ask:**
- **Project-specific signals**: file paths, directory names, project commands (`pnpm`, `cargo`), repo tooling, architecture decisions, specific dependencies
- **Global signals**: personal preferences, general coding style, communication preferences, universal behaviors

**Only ask when genuinely ambiguous.** When asking, use the AskUserQuestion tool:
```
question: "Where should this be saved?"
header: "Scope"
options:
  - label: "Project CLAUDE.md"
    description: "Applies to this repository only"
  - label: "Global ~/.claude/CLAUDE.md"
    description: "Applies to all your projects"
metadata:
  source: "remember"
```

## Step 3: Analyze Target File & Plan Placement

Read the target CLAUDE.md and:
- Understand its structure and style (bullets vs prose, heading levels)
- Find logical placement--prefer existing sections over creating new ones
- Check for related content to update rather than duplicate

**If placement is obvious:** Proceed without asking (e.g., "use const over let" clearly goes in Code Style)

**If multiple sections fit equally well:** Use AskUserQuestion with section options:
```
question: "Which section fits best?"
header: "Placement"
options:
  - label: "[Section A]"
    description: "Groups with [related content]"
  - label: "[Section B]"
    description: "Groups with [related content]"
metadata:
  source: "remember"
```

## Step 4: Present and Execute

Show the user:
- The exact text being added/changed
- Where it will go (file path + section name)

Then use AskUserQuestion for final approval:
```
question: "Add this to CLAUDE.md?"
header: "Confirm"
options:
  - label: "Yes, add it"
    description: "[brief preview of the entry]"
  - label: "Edit first"
    description: "I want to adjust the wording"
metadata:
  source: "remember"
```

- On **"Yes, add it"** -> Execute immediately with the Edit tool, then show the updated section
- On **"Edit first"** -> Ask what to change using AskUserQuestion with common adjustments as options, then re-present

## Guidelines

- **Concise**: Entries should be brief and scannable
- **Imperative mood**: "Use early returns" not "You should use early returns"
- **No fluff**: Skip "Remember to..." or "Always..."--just state the rule
- **Group logically**: Add to existing sections when possible
- **Preserve style**: Match heading levels, bullet style, and tone of existing content

## Examples of Good Entries

```markdown
## Code Style
- Prefer `const` over `let` when variable won't be reassigned
- Use named exports, not default exports

## This Project
- Run `pnpm test:unit` before committing--CI uses this
- The `legacy/` folder is deprecated; don't add new code there
```

## If CLAUDE.md Doesn't Exist

Create with minimal structure, then add content:
```markdown
# Project Guidelines

## Code Style

## Patterns

## Notes
```