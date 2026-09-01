#!/bin/bash
input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "unknown"')
session_name=$(printf '%s' "$input" | jq -r '.session_name // empty')
transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // empty')

used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
ctx=""
if [ -n "$used_pct" ]; then
  ctx=$(printf 'ctx:%.0f%%' "$used_pct")
fi

five_hour=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate=""
if [ -n "$five_hour" ]; then
  rate=$(printf '5h:%.0f%%' "$five_hour")
fi

# ANSI colors, dimmed for terminal compatibility
DIM=$'\033[2m'
RESET=$'\033[0m'
CYAN=$'\033[2;36m'
YELLOW=$'\033[2;33m'
MAGENTA=$'\033[2;35m'
GREEN=$'\033[2;32m'
BLUE=$'\033[2;34m'

parts=()
parts+=("${CYAN}${model}${RESET}")
[ -n "$session_name" ] && parts+=("${MAGENTA}${session_name}${RESET}")
[ -n "$ctx" ] && parts+=("${YELLOW}${ctx}${RESET}")
[ -n "$rate" ] && parts+=("${GREEN}${rate}${RESET}")
[ -n "$transcript_path" ] && parts+=("${BLUE}${transcript_path}${RESET}")

out=""
for p in "${parts[@]}"; do
  if [ -z "$out" ]; then
    out="$p"
  else
    out="$out ${DIM}|${RESET} $p"
  fi
done

printf '%s' "$out"
