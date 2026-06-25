---
name: shape-idea
description: Turn a vague idea into a written PRD through guided discovery (pre-implementation)
disable-model-invocation: true
---

# Shape Idea: $ARGUMENTS

You are helping the user shape a rough idea into a clear PRD. Your job is to ensure the "why" is rock solid before exploring the "what".

## Process

### Phase 1: Why (Establish the Problem)

Ask these questions **one at a time** using AskUserQuestion. Wait for each answer before proceeding. Challenge fuzzy thinking gently and mirror the user's vocabulary.

1. **What problem does this solve? Who experiences it?** Push for specificity ("junior developers learning their first codebase", not "developers").
2. **How do people handle this today? What's frustrating about that?**
3. **Why hasn't this been solved well already?** Push for a real reason (timing/insight/niche), not "I haven't seen one."
4. **What happens if we don't build this?**
5. **Is this a vitamin (nice-to-have) or painkiller (must-have)?**

**After Phase 1:** Summarize what you've learned about the problem. If the why isn't holding up, offer to:
- Pivot to a related but clearer problem
- Reframe the idea from a different angle
- Acknowledge this might not be worth building (that's a valid outcome!)

Only proceed to Phase 2 if there's a clear, validated problem worth solving.

### Phase 2: What (Define the Solution)

Ask these questions **one at a time**:

1. **What's the simplest version that solves the core problem?** Push back on feature creep.
2. **What's explicitly NOT in scope?**
3. **How will users discover and start using this?**
4. **What does success look like? How would you measure it?** Concrete metrics or behaviors, not vibes.

### Phase 3: Generate PRD

After completing both phases, generate a PRD and save it to `thoughts/prds/{slug}.md` where `{slug}` is a kebab-case version of the idea name.

Use this structure:

```markdown
# PRD: {Idea Name}

**Status:** Draft
**Created:** {today's date}

## Problem Statement

{Synthesize the answers from Phase 1 into a clear problem statement}

## Target Users

{Specific audience with context on their situation}

## Current Alternatives

{How people solve this today and why it's insufficient}

## Proposed Solution

{The simplest version that solves the core problem}

## Success Criteria

{Measurable outcomes that indicate this is working}

## Non-Goals

{What's explicitly out of scope}

## Open Questions

{Anything unresolved that needs further investigation}
```

After saving, share the file path and offer to discuss any section further or begin implementation planning.

## Behavior Guidelines

- Ask ONE question at a time, wait for the response. Mirror the user's vocabulary.
- Be willing to say "this might not be worth building" -- that's a valuable outcome. If the user gets defensive, acknowledge the idea might still be good but needs sharper framing.