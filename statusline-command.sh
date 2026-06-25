#!/bin/bash

# Status line - shows model and context usage

data=$(cat)

# Get model name and make it compact
# Extracts just the version part (e.g., "Opus 4.5" from "Claude Opus 4.5")
full_model=$(echo "$data" | jq -r '.model.display_name // .model.id // "unknown"')
model=$(echo "$full_model" | sed -E 's/^Claude //' | sed -E 's/^3\.5/3.5/' | awk '{print $1, $2}')

# Get the last-selected Claude profile (set by the claude-use shell function).
# This reflects which settings file is active, not the authenticated account.
profile=$(cat ~/.claude/.active-profile 2>/dev/null)

# Get context info
max_ctx=$(echo "$data" | jq -r '.context_window.context_window_size // 200000')
used_pct=$(echo "$data" | jq -r '.context_window.used_percentage // empty')

# Color codes
BLUE='\033[34m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Format context display
if [ -z "$used_pct" ] || [ "$used_pct" = "null" ]; then
  # Loading state - empty circles
  context_info="○○○○○○○○○○ loading..."
else
  pct=$(printf "%.0f" "$used_pct" 2>/dev/null || echo "$used_pct")
  [ "$pct" -gt 100 ] 2>/dev/null && pct=100

  # Calculate tokens in k
  used_k=$(( max_ctx * pct / 100 / 1000 ))
  max_k=$(( max_ctx / 1000 ))

  # Build circle bar (10 segments)
  bar=""
  filled=$(( pct / 10 ))

  # Blue by default, red when > 60%
  if [ "$pct" -gt 60 ]; then
    COLOR="$RED"
  else
    COLOR="$BLUE"
  fi

  for i in 0 1 2 3 4 5 6 7 8 9; do
    if [ "$i" -lt "$filled" ]; then
      bar="${bar}${COLOR}●${RESET}"
    else
      bar="${bar}○"
    fi
  done

  context_info="${bar} ${used_k}k/${max_k}k (${pct}% used)"
fi

# Get git repo and branch (if applicable)
git_info=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
  # Use git-common-dir to get the main repo name (works in worktrees)
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  if [ "$git_common_dir" != ".git" ] && [ "$git_common_dir" != "." ]; then
    # Linked worktree: git-common-dir points to main repo's .git dir
    repo_name=$(basename "$(dirname "$git_common_dir")")
  else
    # Main worktree or normal repo
    repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
  fi
  branch=$(git branch --show-current 2>/dev/null)
  current_branch="$branch"  # untruncated, for the remote-branch sync check below
  # Truncate long branch names: show ...last20chars if over 23
  if [ -n "$branch" ] && [ "${#branch}" -gt 23 ]; then
    branch="...${branch: -20}"
  fi
  if [ -n "$branch" ]; then
    git_info="${repo_name}:${branch}"
  elif head=$(git rev-parse --short HEAD 2>/dev/null); then
    # Detached HEAD state
    git_info="${repo_name}:${head}"
  fi

  # Keep origin/main reasonably fresh without blocking the status line:
  # kick off a detached `git fetch` at most once per 60s. The stamp is
  # touched before launching so an offline machine can't spawn a storm of
  # retries (FETCH_HEAD only updates on success, the stamp on every attempt).
  stamp=$(git rev-parse --git-path statusline-fetch-stamp 2>/dev/null)
  if [ -n "$stamp" ]; then
    now=$(date +%s)
    last=0
    [ -f "$stamp" ] && last=$(stat -f %m "$stamp" 2>/dev/null || stat -c %Y "$stamp" 2>/dev/null || echo 0)
    if [ $(( now - last )) -ge 60 ]; then
      touch "$stamp" 2>/dev/null
      ( git fetch --quiet >/dev/null 2>&1 & )
    fi
  fi

  # Diff stats vs main: counts committed branch work + uncommitted edits,
  # using the merge-base so main advancing doesn't pollute the count.
  # Prefer the remote-tracking ref (origin/main) so the indicators reflect
  # the real upstream, not a possibly-stale local main; fall back to local.
  main_ref=""
  for candidate in refs/remotes/origin/main refs/remotes/origin/master refs/heads/main refs/heads/master; do
    if git show-ref --verify --quiet "$candidate"; then
      main_ref=${candidate#refs/remotes/}
      main_ref=${main_ref#refs/heads/}
      break
    fi
  done
  if [ -n "$main_ref" ]; then
    merge_base=$(git merge-base "$main_ref" HEAD 2>/dev/null)
    if [ -n "$merge_base" ]; then
      shortstat=$(git diff --shortstat "$merge_base" 2>/dev/null)
      added=$(echo "$shortstat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
      removed=$(echo "$shortstat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')
      added=${added:-0}
      removed=${removed:-0}
      if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
        git_info="${git_info} ${GREEN}+${added}${RESET} ${RED}-${removed}${RESET}"
      fi
      # How far behind remote main: commits on main not yet in HEAD.
      behind=$(git rev-list --count "HEAD..${main_ref}" 2>/dev/null)
      if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
        git_info="${git_info} ${YELLOW}⌂↓${behind}${RESET}"
      fi
    fi
  fi

  # Sync vs this branch's own remote (origin/<branch>), if that ref exists.
  # ahead = local commits not yet pushed; behind = remote commits not pulled.
  if [ -n "$current_branch" ] && git show-ref --verify --quiet "refs/remotes/origin/${current_branch}"; then
    counts=$(git rev-list --left-right --count "HEAD...origin/${current_branch}" 2>/dev/null)
    ahead=$(echo "$counts" | awk '{print $1}')
    rbehind=$(echo "$counts" | awk '{print $2}')
    sync=""
    [ -n "$ahead" ] && [ "$ahead" -gt 0 ] && sync="${sync}↑${ahead}"
    [ -n "$rbehind" ] && [ "$rbehind" -gt 0 ] && sync="${sync}↓${rbehind}"
    [ -n "$sync" ] && git_info="${git_info} ${YELLOW}☁${sync}${RESET}"
  fi
fi

# Profile prefix (if set): color-code so the active account is obvious at a glance
profile_info=""
if [ -n "$profile" ]; then
  case "$profile" in
    bedrock)    PCOLOR="$YELLOW" ;;
    enterprise) PCOLOR="$BLUE" ;;
    personal)   PCOLOR="$GREEN" ;;
    *)          PCOLOR="$RESET" ;;
  esac
  profile_info="${PCOLOR}[${profile}]${RESET} "
fi

# Output: [Profile] Model | Git (if applicable) | Context
if [ -n "$git_info" ]; then
  printf '%b' "${profile_info}${model} | ${git_info} | ${context_info}"
else
  printf '%b' "${profile_info}${model} | ${context_info}"
fi
