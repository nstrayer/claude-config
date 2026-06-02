---
name: signoff
description: "Runs an interactive end-of-day debrief (a Signoff): seeds from today's Claude Code/Codex logs, interviews the user, and writes a forward-looking Handoff to the top of their next working day's Obsidian note. Use when the user wants to wrap up their day, do an end-of-day debrief or signoff, capture what to start on tomorrow, or types /signoff."
---

# Signoff

Interactive end-of-day debrief. Seeds from today's logs, interviews the user, and
writes a **Handoff** (enriched recap + where to start tomorrow) to the top of the
next working day's Obsidian note. Rationale and the full design live in
`/Users/nicholasstrayer/dev/my-day-notes/docs/superpowers/specs/2026-06-01-signoff-design.md`.

Pipeline (this machine):
- Extractor: `/Users/nicholasstrayer/dev/my-day-notes/extract-day-notes`
- Writer:    `/Users/nicholasstrayer/dev/my-day-notes/write-day-note`
- Notes:     `~/Documents/Nick's Vault/daily/<YYYY-MM-DD>.md` (ISO names)

## Flow

1. **Target day.** Compute the next working day (Mon-Thu -> +1; Fri/Sat/Sun -> Mon)
   using `date`. Announce it; let the user redirect for holidays/PTO. Use the
   confirmed date for the write -- don't re-derive it later.

2. **Seed.** Run `extract-day-notes "$(date +%F)"`. Exit 2 means no AI-session
   activity today -- that's fine, non-logged work still matters, so don't present an
   empty recap as the whole day. Note the repos touched.

3. **Gather while they type.** In ONE message, spawn background agents
   (`run_in_background: true`) AND prompt the brain-dump -- their typing is the
   parallel window. Agents:
   - Deeper re-read of today's transcripts (`~/.claude/projects/<encoded>/*.jsonl`,
     `~/.codex/sessions/YYYY/MM/DD/`) for TODOs, unfinished work, "next I'll...".
   - Open PR / review status via `gh` for the touched repos.
   Pull yourself (Google Calendar MCP): today's events (recap) + the target day's
   events (focus time). Do NOT gather git, Slack, email, or Jira.
   Prompt, roughly: "Brain-dump your day and tomorrow -- including non-AI work
   (manual coding, meetings, reviews). I'm gathering context while you type."

4. **Merge + follow-ups.** Collect agent results. Frame log material as "what the
   logs caught," never the whole day. Ask a SMALL number of pointed follow-ups, only
   where tomorrow's next step isn't already clear. Skip if it's clear.

5. **Draft + confirm.** Draft the six sections below (omit any that would be empty).
   Do NOT include the `<!-- signoff:handoff:... -->` markers -- the writer owns them.

   ```markdown
   ## Handoff from <Weekday Mon D>

   **Recap:** Short, enriched "what the logs caught" + dictated non-logged work.

   ### Start here
   1. Most important first thing to pick up

   ### Open threads
   - repo (`branch`): current state -- next step

   ### Blockers / waiting on
   - ...

   ### Decisions
   - ...

   ### Worth remembering
   - ...

   *From the [[<today's YYYY-MM-DD>]] signoff.*
   ```

6. **Write.** Save the confirmed draft to a temp file, then:
   `write-day-note --handoff "<target-date>" /path/to/handoff.md`
   Tell the user the path written. Re-running a Signoff replaces the prior Handoff.

## Notes
- Manual only; no scheduled trigger (the session needs the user present).
- User-global so it runs from any repo.
