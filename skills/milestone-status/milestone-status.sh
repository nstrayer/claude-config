#!/usr/bin/env bash
# What's left for me this milestone on Positron.
# Usage: ./milestone-status.sh ["Milestone Title"]   (defaults to soonest open milestone)
set -eo pipefail  # ponytail: no -u; empty-array expansion breaks on macOS bash 3.2

REPO="${GH_REPO:-posit-dev/positron}"
ME="${GH_ME:-$(gh api user --jq .login)}"
[[ -n "$ME" ]] || { echo "Not authenticated to GitHub (gh api user failed). Try: gh auth login" >&2; exit 1; }

# --- milestones fetched once, reused for pick + metadata ---
MS_JSON=$(gh api "repos/$REPO/milestones?state=open&per_page=100")

# --- pick milestone: arg, else soonest open one whose due date hasn't passed (date-only compare) ---
MILESTONE="${1:-}"
if [[ -z "$MILESTONE" ]]; then
  MILESTONE=$(jq -r '
    (now|gmtime|strftime("%Y-%m-%d")) as $today
    | [.[] | select(.due_on != null)] | sort_by(.due_on)
    | (map(select(.due_on[0:10] >= $today)) | .[0].title) // (.[-1].title) // empty' <<<"$MS_JSON")
fi
[[ -n "$MILESTONE" ]] || { echo "No open milestone found." >&2; exit 1; }

read -r DUE TEAM_CLOSED < <(jq -r --arg m "$MILESTONE" \
  '.[] | select(.title==$m) | "\(.due_on) \(.closed_issues)"' <<<"$MS_JSON")

if [[ -z "$DUE" || "$DUE" == null ]]; then
  DUE_TXT="(no due date)"; DAYS_TXT="days remaining: ?"
else
  due_epoch=$(date -j -f "%Y-%m-%d" "${DUE%%T*}" "+%s")
  today_epoch=$(date -j -f "%Y-%m-%d" "$(date +%Y-%m-%d)" "+%s")
  DUE_TXT="${DUE%%T*}"; DAYS_TXT="$(( (due_epoch - today_epoch) / 86400 )) days remaining"
fi

# --- lines of "issue# pr#" for my open PRs that close an issue (no assoc array: macOS bash 3.2) ---
PRS_JSON=$(gh pr list --repo "$REPO" --author "$ME" --state open --json number,title,body --limit 100)
PR_LINKS=$(echo "$PRS_JSON" | jq -r '
  .[] | .number as $p | [ (.body // "") | scan("(?i)(?:clos|fix|resolv)\\w*\\s+#(\\d+)") ] | .[] | "\(.[0]) \($p)"')
pr_for() { awk -v i="$1" '$1==i{print $2; exit}' <<<"$PR_LINKS"; }

# --- classify each open issue assigned to me ---
ISSUES_JSON=$(gh issue list --repo "$REPO" --assignee "$ME" --milestone "$MILESTONE" --state open \
  --json number,title,assignees --limit 200)

IMPL=(); REVW=(); UNCLEAR=()
while IFS=$'\t' read -r num assignees title; do
  pr="$(pr_for "$num")"
  pr_tag=""; [[ -n "$pr" ]] && pr_tag="  -> PR #$pr"
  if [[ "$assignees" == "$ME" ]]; then
    IMPL+=("#$num  $title$pr_tag")
  elif [[ -n "$pr" ]]; then
    IMPL+=("#$num  $title$pr_tag")              # I'm writing the PR -> I'm the implementer
  else
    # multi-assignee: latest "Author:/Implementer:" and "Reviewer:" anywhere in the comments
    roles=$(gh api "repos/$REPO/issues/$num/comments" --jq '
      [ .[] | (.body // "") | capture("(?i)(?:author|implementer):\\s*@(?<x>[\\w-]+)").x ] as $a
      | [ .[] | (.body // "") | capture("(?i)reviewer:\\s*@(?<x>[\\w-]+)").x ] as $r
      | "\($a[-1] // "")|\($r[-1] // "")"')
    author="${roles%%|*}"; reviewer="${roles##*|}"
    others=$(echo "$assignees" | tr ',' '\n' | grep -vx "$ME" | paste -sd, -) || true
    if [[ "$author" == "$ME" ]]; then
      IMPL+=("#$num  $title$pr_tag")
    elif [[ "$reviewer" == "$ME" ]]; then
      REVW+=("#$num  $title  (author: ${author:-$others})")
    else
      UNCLEAR+=("#$num  $title  (assignees: $assignees)")
    fi
  fi
done < <(echo "$ISSUES_JSON" | jq -r '.[] | "\(.number)\t\(.assignees|map(.login)|join(","))\t\(.title)"')

MY_DONE=$(gh issue list --repo "$REPO" --assignee "$ME" --milestone "$MILESTONE" --state closed --json number --jq length)

PRS=()
while IFS= read -r line; do PRS+=("$line"); done < <(echo "$PRS_JSON" | jq -r '.[] | "#\(.number)  \(.title)"')

# --- report ---
section() { local title="$1"; shift; printf "\n%s (%d)\n" "$title" "$#";
  if (($#)); then printf '  %s\n' "$@"; else printf '  (none)\n'; fi; }

printf "MILESTONE: %s\n" "$MILESTONE"
printf "Due %s  -  %s\n" "$DUE_TXT" "$DAYS_TXT"
printf "Closed by you this milestone: %d   (team total closed: %d)\n" "$MY_DONE" "$TEAM_CLOSED"
section "You're the IMPLEMENTER" "${IMPL[@]}"
section "You're the REVIEWER" "${REVW[@]}"
section "Multi-assignee, role not set in a comment" "${UNCLEAR[@]}"
section "Your open PRs in flight" "${PRS[@]}"
