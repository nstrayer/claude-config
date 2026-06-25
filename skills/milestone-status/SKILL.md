---
name: milestone-status
description: Show what's left for me this milestone on Positron
---

# Milestone status (Positron)

Show the user where things stand for the current milestone so they can pick what to work on next.

## Run

```bash
~/.claude/skills/milestone-status/milestone-status.sh "$ARGUMENTS"
```

`$ARGUMENTS`, if set, is a milestone title (e.g. `"2026.08.0 Release"`); otherwise the script auto-picks the soonest open milestone whose due date hasn't passed. Requires the `gh` CLI authenticated as the user.

## How the script classifies issues

- Only the user assigned -> they're the implementer.
- User authored an open PR that closes the issue -> implementer (overrides any comment).
- Multiple assignees -> reads the latest `Author:`/`Reviewer:` comment on the issue (the team uses "Author" to mean implementer; both words are matched).
- Multiple assignees with no role comment -> reported under "role not set" so the user knows to add one.

## Categorize the implementer issues by effort (Tier 0-3)

After the script prints, tier the **implementer** issues by how much work is left, mirroring the user's triage doc. Skip the reviewer / role-not-set buckets - those aren't the user's to size.

**Investigate, don't guess.** Issue bodies and prior triage notes go stale: a past run of this found three issues already closed and two whose notes named the wrong file. Every tier call must be checked against current GitHub state and current code, not the issue text alone.

Spawn one investigation subagent per implementer issue, all in a **single parallel batch**. Give each agent only the issue number, `$REPO`, and the checkout path (below). Each returns a tight verdict - tier + one-line "what's left" + `file:line` refs + the issue's `area:`/`theme:` labels and any cross-references (blocked-by / part-of-epic / duplicate-of another issue or PR) - never an essay. Each agent must:

1. **Check current state:** `gh issue view {N} --repo $REPO --json state,closedAt,stateReason,labels` and whether a PR already implements it (`gh pr list --repo $REPO --search "{N} in:body" --state all`). If it's closed or already shipped, report that - it's Tier 0.
2. **Confirm the claims still hold:** read the relevant code in the checkout. Verify the file/symbol the issue blames still exists and the fix isn't already applied. Flag any stale assumption explicitly.
3. **Assign a tier:**
   - **Tier 0 - already exists, just needs landing:** an open PR implements it, or it's already shipped (verify-and-close).
   - **Tier 1 - small, self-contained:** half a day or less; clear scope, few files, ready diff.
   - **Tier 2 - medium:** 1-2 days; clear scope but real surface area or design judgment needed.
   - **Tier 3 - large:** 3+ days, or an investigation with an unknown root cause.
4. **Note relationships:** report the subsystem it touches (e.g. notebook AI/LLM, notebook cell UI, data explorer) and any issue/PR it is blocked by, part of (epic/umbrella), unblocks, or duplicates. The body and labels usually say; a quick code read confirms which files it shares with its neighbors.

**Finding the checkout:** look for a local clone of `$REPO` (search under `~/dev`); if none is found, tell the user and ask for the path rather than guessing. An agent that can't read code locally falls back to `gh api repos/$REPO/contents/...`.

Assemble the verdicts into a Tier 0 -> Tier 3 list, ranked by effort within each tier, each with its one-line "what's left".

**Then cluster the issues into related groups.** Using the agents' subsystem + relationship reports, group issues two ways:
- **By theme/subsystem** - e.g. all notebook AI/LLM issues, all cell-UI polish, all data-explorer issues. Use shared `area:`/`theme:` labels and shared files as the signal.
- **By dependency chain** - issues that land or unblock together behind the same PR or epic. Name the tie explicitly, e.g. "Notebook LLM migration (gated on PR #13730): closes #X #Y, unblocks #Z". Umbrella/epic issues are natural anchors.

An issue can appear in both a tier and a cluster; clusters are a second view, not a re-bucketing. They tell the user where landing one thing clears several.

## Present the result

Relay the script's output as a tight summary, leading with the headline numbers: days remaining, how many the user has closed, the count of implementer issues with no PR, and the Tier 0-3 breakdown (how many in each tier). Then present the implementer issues grouped **Tier 0 -> Tier 3** (ranked by effort, each with its one-line "what's left"), followed by the reviewer / role-not-set / in-flight-PR sections. Don't dump raw script output if a cleaner summary reads better - keep issue numbers (they're clickable) and PR links intact.

Finish with a short **Related groups** view: the theme clusters and the dependency chains, each naming the tie that binds it (e.g. "land PR #13730 -> closes #X #Y, unblocks #Z"). This is where the user spots that one merge clears several issues, so keep it to a few named clusters, not a re-listing of every issue.

## Follow-up: start a fix

After the summary, add one line offering the next step: "Want a handoff prompt to start fixing one of these?"

If the user names an issue, emit the paste-ready prompt below with `{N}` and `{TITLE}` filled in from that issue (grab the title from the status output). It is meant to be pasted into a fresh agent or worktree, so it points that agent at the existing `diagnose`, `tdd`, and `branch-quality-review` skills rather than re-explaining them, and adds two independent-verification gates. Emit only the prompt - do not start fixing the issue yourself in this session.

```text
You are fixing posit-dev/positron issue #{N}: "{TITLE}".

Done means: a new test that fails for the reason the issue describes now passes, the relevant
test suite stays green, and the build/typecheck pass. Never edit or delete existing tests to get
there. Keep the change surgical - touch only what the fix requires.

First read the issue and the repo's own conventions:
  gh issue view {N} --repo posit-dev/positron --json title,body,comments
  then skim the repo-root CLAUDE.md / CONTRIBUTING for how to run tests and build.

Work on a fresh branch off main (or a worktree). Follow this flow; do not skip the gates.

1. REPRODUCE WITH A TEST. Use the `diagnose` and `tdd` skills to write a deterministic test that
   asserts the exact symptom the issue describes and fails for that reason (not an incidental
   one). It must live in the project's real test suite so it persists in CI. Don't fix anything yet.

   GATE 1 - independent test verification. Spawn independent subagents (2 is enough for a small
   issue; scale up for a subtle one). Give each: the verbatim issue text, its stated
   repro/acceptance criteria, the test, and read access to the branch - but NOT your verdict or
   reasoning. Ask each to try to REFUTE the test: find an input where it passes while the bug is
   still present, or where it fails for the wrong reason. Each returns a short verdict (captures /
   adjacent / weaker) plus the weakest assertion as file:line - not an essay. You are the decider:
   weigh the objections, revise once, re-check. Cap at 2 rounds; if they still split, the issue's
   acceptance criteria are ambiguous - stop and report that rather than weakening the test to force
   agreement.

2. FIX using that test. Drive it with the `tdd` red->green loop until your test and the relevant
   suite are green and the build passes. Commit after the test is locked and again after the fix is
   green (do not push or open a PR) so progress is recoverable.

   GATE 2 - independent review. Spawn 2-3 subagents, each running `branch-quality-review
   --read-only` on the branch. They flag only findings that affect correctness or the issue's
   stated behavior; treat pure architecture/style as optional and don't act on it unless it touches
   the fix (a reviewer told to "find gaps" will manufacture scope creep - resist it). Address what
   matters, re-run the suite.

If at any point you cannot build a failing test, the issue admits more than one reasonable
interpretation, or a gate won't converge - STOP and report what you found and the exact decision
you need from me. Do not guess a fix or weaken a test to get past a gate.

3. STOP before opening a PR. Report, with evidence pasted (not summarized):
   - Issue + your one-line interpretation
   - Test: file, what it asserts, and the failure message it produced BEFORE the fix
   - Fix: files touched + one-line rationale each
   - Gate 1: each subagent's verdict + the final test revision
   - Gate 2: findings kept vs dismissed + what changed
   - Verification: relevant suite + build status (the actual command output)
   - Anything you could NOT verify / open questions
   Wait for my review.
```
