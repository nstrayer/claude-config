---
name: obsidian-note
description: Record a persistent reference note in the Obsidian vault, organized by repo/context and theme
---

Record a note in the Obsidian vault under `~/Documents/Nick's Vault/claude-notes/`.

## Steps

1. **Determine context name.**

   Run:
   ```bash
   git remote get-url origin 2>/dev/null
   ```
   - If successful, extract the repo name: take the last path component and strip any `.git` suffix.
     Examples: `git@github.com:posit-dev/positron.git` -> `positron`,
     `https://github.com/nstrayer/my-day-notes.git` -> `my-day-notes`.
   - If the command fails (not a git repo), use the basename of the current working directory.

   Store this as `<context>`.

2. **Scan existing theme files.**

   ```bash
   ls ~/Documents/Nick\'s\ Vault/claude-notes/<context>/ 2>/dev/null
   ```

   If the directory does not exist, that is fine -- you will create it in step 5.
   Note which theme files already exist (if any).

3. **Decide the theme.**

   Based on the user's message and any existing theme files from step 2:
   - If an existing theme file clearly matches the topic, plan to append to it.
   - If no existing file matches, choose a descriptive kebab-case name for a new file (e.g., `renderer-tradeoffs.md`, `api-design-decisions.md`).
   - If it is genuinely ambiguous which existing file to use, ask the user. Present the existing files as numbered options plus a "create new" option. Do NOT ask if the choice is reasonably clear.

4. **Generate the note content.**

   Determine the mode from the user's input:
   - **Synthesis mode**: if the input references conversation context ("the tradeoffs we just discussed", "what we decided about X", "summarize our discussion on..."), read back through the conversation, extract the key decisions, reasoning, and alternatives considered, and write a clear, concise note.
   - **Capture mode**: if the input is self-contained ("the API rate limit is 100/min", "Nick prefers X for Y reason"), format and clean it up without embellishing.

   Write the note so it is useful to someone with no memory of this conversation. Avoid dangling references like "as we discussed" without explaining what was discussed.

   Format as plain markdown (no YAML frontmatter, no Obsidian tags). Do not include a date header -- that is added in step 5.

5. **Write the note to the vault.**

   If the theme file already exists, read it first, then prepend the new entry with a date header:

   ```markdown
   ## YYYY-MM-DD

   <generated content>

   ```

   Add a blank line after the content, then the existing file contents. This keeps entries in reverse chronological order.

   If the theme file does not exist, create the directory and file:

   ```bash
   mkdir -p ~/Documents/Nick\'s\ Vault/claude-notes/<context>/
   ```

   Then write the file with just the new entry (date header + content).

6. **Confirm to the user.**

   Tell the user what was written and where, showing the full path:
   `~/Documents/Nick's Vault/claude-notes/<context>/<theme>.md`

   If you appended to an existing file, mention that. If you created a new file, mention that.

## Notes

- The date in the entry header is today's date in YYYY-MM-DD format.
- Theme file names should be descriptive and use kebab-case.
- When appending to an existing file, preserve all existing content exactly -- only prepend the new entry.
- Do not create any Obsidian-specific metadata (tags, aliases, properties). Keep it plain markdown.
