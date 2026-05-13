---
name: update-notes
description: Generate or update today's daily work journal from Claude Code and Codex conversation history
---

Update the daily work journal in the Obsidian vault.

## Steps

1. Run the extractor to get today's normalized session data:

```bash
/Users/nicholasstrayer/dev/my-day-notes/extract-day-notes "$(date +%F)"
```

If it exits with status 2, tell the user there is no assistant activity for today and stop.

2. Save the JSON output to a temporary file.

3. Read the summarization prompt from `/Users/nicholasstrayer/dev/my-day-notes/prompt.md`.

4. Using the prompt instructions and the extracted JSON, produce the generated markdown content.
   Do NOT include the `<!-- day-notes:auto:start -->` or `<!-- day-notes:auto:end -->` markers
   in your output -- the writer handles those.

   If the user provided guidance after the command (e.g., "/update-notes focus on the fact
   we pivoted from X to Y", "/update-notes emphasize the auth refactor"), incorporate that
   guidance into your summary. The guidance should shape emphasis, framing, and what gets
   highlighted -- but the summary should still be grounded in the actual session data.
   Do not fabricate details that aren't in the extracted JSON.

5. Save the generated markdown to a temporary file.

6. Run the writer to update the Obsidian note:

```bash
/Users/nicholasstrayer/dev/my-day-notes/write-day-note "$(date +%F)" /path/to/generated.md
```

7. Tell the user the note has been updated, and show the path:
   `~/Documents/Nick's Vault/daily/YYYY-MM-DD.md`

## Notes

- The user may specify a date other than today (e.g., "/update-notes for yesterday").
  In that case, pass the appropriate YYYY-MM-DD to both the extractor and writer.
- If the extractor or writer fails, show the error output to the user.
