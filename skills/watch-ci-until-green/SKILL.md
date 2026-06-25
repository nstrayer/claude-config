---
name: watch-ci-until-green
description: Watch a Positron PR's CI checks until they all pass, auto-fixing easy failures. Use after pushing a branch/PR when asked to "watch CI", "wait until green", "babysit the checks", or to drive a PR's CI run to a green finish.
---

# Watch CI until green

After a push, watch every check. If one fails with an easy fix, fix it, repush, and watch again. Stop when all pass, or when a failure is non-trivial (report and stop). Positron CI is slow (~25-50 min), so this runs as a background watch that notifies you once on completion -- you react, you don't sit and poll.

## Preconditions
- Branch pushed and a PR exists. Get the number: `gh pr view --json number -q .number`.
- CI is running on the SHA you just pushed: `gh pr view <PR> --json headRefOid -q .headRefOid` must equal `git rev-parse HEAD`.

## 1. Let checks register first
Right after a push only fast checks (`dependabot`, `RequireCLA`) exist; the heavy jobs (`test / unit`, `test / ext-host`, `e2e / electron`, `e2e-tags`) take a minute to appear. The watch loop below guards against this with a "at least 5 checks registered" floor so it can't exit early on a single passing check.

## 2. Background watch until terminal
Run as a backgrounded Bash command (`run_in_background: true`) -- it exits when all checks are terminal and re-invokes you with one completion notification. Do NOT schedule a separate wakeup to poll it; the harness re-invokes you when it exits.

```bash
PR=<PR>; i=0
while [ $i -lt 90 ]; do
  json=$(gh pr checks "$PR" --json name,bucket 2>/dev/null) || { sleep 60; i=$((i+1)); continue; }
  total=$(jq 'length' <<<"$json")
  pending=$(jq '[.[]|select(.bucket=="pending")]|length' <<<"$json")
  if [ "$total" -ge 5 ] && [ "$pending" -eq 0 ]; then break; fi
  sleep 60; i=$((i+1))
done
echo "=== CI TERMINAL (after ${i} min) ==="
gh pr checks "$PR"
echo "=== FAIL COUNT ==="
gh pr checks "$PR" --json bucket -q '[.[]|select(.bucket=="fail" or .bucket=="cancel")]|length'
```

`bucket` is one of `pass | fail | pending | skipping | cancel`. Treat `fail`/`cancel` as failures; `skipping` is fine (`build` and `e2e` are usually `skipping` by design on this repo).

Alternative for live per-check visibility: the Monitor tool with `persistent: true`, emitting one line per check as it lands (see Monitor's own example). The background loop above is preferred when you just need to react once at the end.

## 3. On failure: fix only if easy
- Get the failing logs: grab the run id from the check URL, then `gh run view <run-id> --log-failed`.
- "Easy" = lint/format/type nit, typo, a clearly-correct snapshot/assertion update (common after a rebase), or an obvious flake to re-run. Anything ambiguous, a real regression, or infra/runner failure: STOP and report -- don't guess.
- Flake: `gh run rerun <run-id> --failed`, then back to step 2.
- Code fix: edit, verify locally (`npx vitest run <file>` for vitest; `npm run build-check` for type/compile), commit, push. Use `git push --force-with-lease` if you amended or rebased. Then back to step 1.

## 4. Stop conditions
- All checks pass (skipping OK) -> report green. Send a PushNotification.
- Non-trivial failure -> report what failed + the log excerpt, then stop. Send a PushNotification.
- Not converging after ~3 fix/repush cycles -> stop and report.

## Notes
- Approx durations last seen: `e2e / electron` ~35-50m, `test / ext-host` ~50m, `test / unit` ~25m.
- Confirm CI is on your new SHA before trusting results -- a force-push creates new check runs; `gh pr checks` reports the latest head commit's checks.
