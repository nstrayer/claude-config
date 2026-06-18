---
name: morning-report
description: Generates a shareable Doing/Blocked morning standup report by distilling today's Handoff and recent activity, then formatting the user's brain-dump for the team. Use when the user wants their morning report or standup, types /morning-report, or needs Doing/Blocked bullets to submit.
---

# Morning report

Generate a short, shareable Doing/Blocked status update for the team, late morning.
Distills today's Handoff + recent activity, merges the user's brain-dump, and hands back
plain text to paste straight into Slack -- no markdown. Posts and saves nothing. See
`/Users/nicholasstrayer/dev/my-day-notes/CONTEXT.md` for how a Morning report relates to
the Handoff (same facts, different audience).

Sources (this machine):
- Extractor:   `/Users/nicholasstrayer/dev/my-day-notes/extract-day-notes`
- Today's note: `~/Documents/Nick's Vault/daily/<YYYY-MM-DD>.md` (holds the Handoff block)

## Flow

1. **Gather** (fast; kick off while the user brain-dumps):
   - Read today's note; extract the `<!-- signoff:handoff:start --> ... :end -->` block
     if present. Its "Start here" -> Doing candidates; "Blockers/waiting" -> Blocked.
   - Run `extract-day-notes "$(date +%F)"` for this morning's real activity (exit 2 = none).
   - `gh` open PR / review status for touched repos -> Blocked signal (waiting on review/CI).
   - Fallback ONLY if today has no Handoff: read the previous working day's auto-block
     (Mon -> previous Fri; else previous day) for what you were last doing.

2. **Brain-dump.** Prompt: "Quick dump -- what are you doing today, and what's blocked?"

3. **Probe for detail.** The first dump is usually terse. Before formatting, ask a couple
   of targeted follow-ups so each bullet carries context and direction, not just a label:
   - Doing: what prompted it, where it stands, what's next (e.g. "liked the prototype
     enough I'll throw up a PR shortly").
   - Blocked: the specific next action that unblocks it (who/what channel, what you'll ask).
   Two or three questions, not an interrogation -- then move on. Lean on the gathered
   activity and earlier answers so you don't ask what you already know.

4. **Merge + format.** Combine the dump with the sources. Reframe for a team audience
   (clean, concise, no private/raw detail). Refresh "Doing" against what's actually been
   touched this morning, not just the plan.

   Output is **plain text for Slack**, paste-ready, no markdown:
   - Plain `Doing` / `Blocked` labels (no `**`, `#`, or `>`).
   - `-` for bullets; indent two spaces for a sub-bullet when one bullet needs more detail.
   - No dash-joined clauses. Use a colon to introduce specifics ("Cutting a quick CSP
     fix: PDFs blocked in Workbench") or just start a new sentence. If it still needs
     room, break it into a nested bullet.
   - Match detail to importance. Collapse routine, bundled work to a single line with no
     numbers -- reviewing others' PRs is just "Finishing up some reviews," not a per-PR
     list. Reserve PR numbers and specifics for your own work items (the PR you're
     building, the ones blocked on review).
   - Group bullets that share a reason under one parent, stated once, with the items as
     nested sub-bullets -- e.g. "A couple of PRs waiting on review:" then each PR
     indented below it. Don't repeat the same blocker phrase on every line.
   - The audience is the people you work alongside, so skip framing words like "teammate(s)"
     and don't re-explain context they already share.
   - Say WHAT you're working on, not HOW. Cut workflow/tooling mechanics like "dispatched
     agents" or "ran the tests." They want progress, not process.
   - First-person, conversational standup voice; state intent ("going to...", "shortly").
     It's a status update, not a changelog.

   ```
   Doing
   - <in flight, with context; new sentence or a colon for the extra detail>
   - <in flight>

   Blocked
   - <single blocker>
     - <the next action that unblocks it>
   - <shared blocker, stated once>:
     - <item>
     - <item>
   ```

   A handful of Doing bullets; Blocked only if real, else just "None".

5. **Show + refine.** Present the draft; the user tweaks in chat. When they're happy,
   output the final report inside a fenced ``` code block on its own, with no prose after
   it, so `/copy` grabs exactly the report and nothing else. The text inside stays plain
   (Slack-ready, no markdown) -- the fence is only the copy container. Do NOT post or save
   anything.

## Notes
- Manual; run late morning.
- Robust to no Handoff -- fall back to activity + the previous day's auto-summary, and
  lean on the dump.
- User-global so it runs from any repo.
