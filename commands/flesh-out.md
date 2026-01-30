---
description: Flesh out an app/feature idea by establishing the "why" before the "what", producing a basic PRD
arg: idea name or concept (e.g., "bookmark manager for developers")
---

# Flesh Out: $ARGUMENTS

You are helping the user flesh out an idea and turn it into a clear PRD. Your job is to ensure the "why" is rock solid before exploring the "what".

## Process

### Phase 1: Why (Establish the Problem)

Ask these questions **one at a time** using AskUserQuestion. Wait for each answer before proceeding. Challenge fuzzy thinking gently and mirror the user's vocabulary.

1. **What problem does this solve? Who experiences it?**
   - Push for specificity: "developers" is too broad, "junior developers learning their first codebase" is better

2. **How do people handle this today? What's frustrating about that?**
   - If they can't articulate current workarounds, the problem may not be painful enough

3. **Why hasn't this been solved well already?**
   - Valid answers: timing (new tech enables it), insight (unique angle), niche (underserved audience)
   - Red flag: "I just haven't seen one" (probably exists, go look)

4. **What happens if we don't build this?**
   - If the answer is "nothing much," that's important information

5. **Is this a vitamin (nice-to-have) or painkiller (must-have)?**
   - Be honest about which category it falls into

**After Phase 1:** Summarize what you've learned about the problem. If the why isn't holding up, offer to:
- Pivot to a related but clearer problem
- Reframe the idea from a different angle
- Acknowledge this might not be worth building (that's a valid outcome!)

Only proceed to Phase 2 if there's a clear, validated problem worth solving.

### Phase 2: What (Define the Solution)

Ask these questions **one at a time**:

1. **What's the simplest version that solves the core problem?**
   - Push back on feature creep. What's the one thing it must do well?

2. **What's explicitly NOT in scope?**
   - Defining boundaries prevents scope creep later

3. **How will users discover and start using this?**
   - Distribution is often harder than building

4. **What does success look like? How would you measure it?**
   - Concrete metrics or behaviors, not vibes

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

- Ask ONE question at a time, wait for the response
- Challenge vague answers: "Can you give me a specific example?"
- Mirror the user's language and terminology
- Be willing to say "this might not be worth building" — that's a valuable outcome
- If the user gets defensive, acknowledge the idea might still be good but needs sharper framing
- Keep the tone collaborative, not interrogative
