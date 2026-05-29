---
name: catchup
description: Use when returning to a project after a break and need to reconstruct what was in progress -- read-only orientation from git, Claude Code conversation history, tasks, and notes
---

# Catch Up on Previous Work

Reconstruct what was being worked on so the user can resume. **Read-only: investigate and summarize only -- never edit, commit, or implement.** If the user wants to proceed, they'll say so.

**Focus:** $ARGUMENTS -- if set, filter everything to this topic; if empty, do a general catchup.

## Investigate

Dispatch these as parallel Explore agents in a single message, each returning a tight summary:

1. **Git state** -- current branch, `git status --short`, `git log --oneline -10`, `git diff --stat` (staged + unstaged), `git stash list`.

2. **Claude Code conversation history** -- recent sessions for this project:

   ```bash
   python3 - <<'PY'
   import json, glob, os, time
   proj = os.path.expanduser('~/.claude/projects/' + os.getcwd().replace('/','-').replace('.','-'))
   for f in sorted(glob.glob(f'{proj}/*.jsonl'), key=os.path.getmtime, reverse=True)[:5]:
       title = last = None
       for line in open(f):
           try: d = json.loads(line)
           except: continue
           if d.get('type') == 'ai-title': title = d.get('aiTitle')
           elif d.get('type') == 'last-prompt': last = d.get('lastPrompt')
       mt = time.strftime('%Y-%m-%d %H:%M', time.localtime(os.path.getmtime(f)))
       print(f'{mt}  {title or "(untitled)"}')
       if last: print(f'    last: {last[:140]}')
   PY
   ```

   Read the most relevant 1-2 full transcripts only if more detail is needed.

3. **Tasks & planning docs** -- `~/.claude/todos/*.json` (in_progress items), recent `~/.claude/plans/*.md`; project `thoughts/`, `**/PLAN*.md`, `**/TODO*.md`, `**/NOTES.md`, handoff docs. Summarize key points; don't dump full contents.

## Summarize

Scannable bullets: branch + uncommitted files, recent work themes, what's in progress (inferred from titles, prompts, todos, change patterns), and one clear recommended next step. Then stop and let the user direct -- decide the most useful follow-up yourself rather than offering a fixed menu.
