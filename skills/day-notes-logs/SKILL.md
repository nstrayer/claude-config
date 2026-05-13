---
name: day-notes-logs
description: Inspect recent day-notes scheduled run logs for failures or status
---

Show the user recent day-notes scheduled run logs.

## Steps

1. Check if log files exist:

```bash
ls -la /Users/nicholasstrayer/dev/my-day-notes/logs/launchd-stdout.log /Users/nicholasstrayer/dev/my-day-notes/logs/launchd-stderr.log
```

2. Show the last 30 lines of stdout:

```bash
tail -30 /Users/nicholasstrayer/dev/my-day-notes/logs/launchd-stdout.log
```

3. Show the last 30 lines of stderr (if non-empty):

```bash
tail -30 /Users/nicholasstrayer/dev/my-day-notes/logs/launchd-stderr.log
```

4. Check if the launchd job is loaded:

```bash
launchctl list | grep day-notes
```

5. Summarize for the user:
   - When was the last successful run?
   - Were there any recent failures?
   - Is the launchd job currently loaded?
   - What was the last note path written?
