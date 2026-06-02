#!/bin/bash

# Status line - shows model and context usage

data=$(cat)

# Get model name and make it compact
# Extracts just the version part (e.g., "Opus 4.5" from "Claude Opus 4.5")
full_model=$(echo "$data" | jq -r '.model.display_name // .model.id // "unknown"')
model=$(echo "$full_model" | sed -E 's/^Claude //' | sed -E 's/^3\.5/3.5/' | awk '{print $1, $2}')

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

  # Diff stats vs main: counts committed branch work + uncommitted edits,
  # using the merge-base so main advancing doesn't pollute the count.
  main_branch=""
  for candidate in main master; do
    if git show-ref --verify --quiet "refs/heads/${candidate}"; then
      main_branch="$candidate"
      break
    fi
  done
  if [ -n "$main_branch" ]; then
    merge_base=$(git merge-base "$main_branch" HEAD 2>/dev/null)
    if [ -n "$merge_base" ]; then
      shortstat=$(git diff --shortstat "$merge_base" 2>/dev/null)
      added=$(echo "$shortstat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+')
      removed=$(echo "$shortstat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+')
      added=${added:-0}
      removed=${removed:-0}
      if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
        git_info="${git_info} ${GREEN}+${added}${RESET} ${RED}-${removed}${RESET}"
      fi
      # How far behind main: commits on main not yet in HEAD.
      behind=$(git rev-list --count "HEAD..${main_branch}" 2>/dev/null)
      if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
        git_info="${git_info} ${YELLOW}↓${behind}${RESET}"
      fi
    fi
  fi
fi

# Output: Model | Git (if applicable) | Context
if [ -n "$git_info" ]; then
  printf '%b' "${model} | ${git_info} | ${context_info}"
else
  printf '%b' "${model} | ${context_info}"
fi
