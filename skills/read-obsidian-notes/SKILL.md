---
name: read-obsidian-notes
description: Read reference notes from the Obsidian vault for the current repo or a specified repo/topic
---

Read notes from `~/Documents/Nick's Vault/claude-notes/`.

## Steps

1. **Determine context name.**

   Run:
   ```bash
   git remote get-url origin 2>/dev/null
   ```
   - If successful, extract the repo name: take the last path component and strip any `.git` suffix.
   - If the command fails (not a git repo), use the basename of the current working directory.

   Store this as `<context>`. If the user specified a different repo or context name, use that instead.

2. **List available notes.**

   ```bash
   ls ~/Documents/Nick\'s\ Vault/claude-notes/<context>/ 2>/dev/null
   ```

   If the directory does not exist, tell the user there are no notes for this context and list available contexts:
   ```bash
   ls ~/Documents/Nick\'s\ Vault/claude-notes/
   ```

3. **Select and read notes.**

   - If the user asked about a specific topic, find the theme file that best matches and read it.
   - If multiple files could match, read all plausible matches.
   - If the user did not specify a topic, list the available theme files and ask which they want to read. If there are 4 or fewer files, just read them all.

4. **Present the content.**

   Summarize what you found. If the user is looking for specific information, extract and highlight the relevant parts rather than dumping the full file contents.
