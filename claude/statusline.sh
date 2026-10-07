#!/bin/bash
input=$(cat)

# Extract model name and usage percentage
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Build status: Model name
status="${model}"

# Progress bar (20 chars wide) with color thresholds (1M = 100%)
bar_width=20
used_int=$(awk "BEGIN {printf \"%.0f\", $used}")
filled=$(awk "BEGIN {printf \"%.0f\", $used * $bar_width / 100}")
[ "$filled" -lt 0 ] 2>/dev/null && filled=0
[ "$filled" -gt "$bar_width" ] 2>/dev/null && filled=$bar_width

# Color and hint based on usage
hint=""
if [ "$used_int" -lt 20 ]; then
  color="\033[0;32m"  # Green
elif [ "$used_int" -lt 40 ]; then
  color="\033[0;33m"  # Yellow
  hint=" 💡 /clear if switching tasks"
elif [ "$used_int" -lt 60 ]; then
  color="\033[38;5;208m"  # Orange
  hint=" ⚠️ /compact recommended"
else
  color="\033[0;31m"  # Red
  hint=" 🔴 /compact or /clear NOW"
fi
reset="\033[0m"

bar=""
for ((i=0; i<filled; i++)); do bar="${bar}█"; done
for ((i=filled; i<bar_width; i++)); do bar="${bar}░"; done

status="${status} | $(printf "${color}")[${bar}] ${used}%${hint}$(printf "${reset}")"

# Token count using ACTUAL context window fields
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_creation=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')

total_tokens=$(awk "BEGIN {printf \"%.0f\", $cache_read + $cache_creation + $input_tokens + $output_tokens}")

# Format with k suffix
if [ "$total_tokens" -ge 1000 ]; then
  tokens_display=$(awk "BEGIN {printf \"%.0f\", $total_tokens / 1000}")k
else
  tokens_display="${total_tokens}"
fi

if [ "$context_size" -ge 1000 ]; then
  context_display=$(awk "BEGIN {printf \"%.0f\", $context_size / 1000}")k
else
  context_display="${context_size}"
fi

status="${status} | ${tokens_display}/${context_display} tokens"

echo "$status"

# Line 2: Git branch + worktree info
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
wt_name=$(echo "$input" | jq -r '.worktree.name // empty')

if [ -n "$branch" ] || [ -n "$wt_name" ]; then
  line2=""
  if [ -n "$branch" ]; then
    line2="$(printf '\033[0;36m')⎇ ${branch}$(printf '\033[0m')"
  fi
  if [ -n "$wt_name" ]; then
    wt_original=$(echo "$input" | jq -r '.worktree.original_branch // empty')
    line2="${line2} $(printf '\033[0;35m')🌳 ${wt_name}$(printf '\033[0m')"
    if [ -n "$wt_original" ]; then
      line2="${line2} $(printf '\033[2m')← ${wt_original}$(printf '\033[0m')"
    fi
  fi
  echo "$line2"
fi
