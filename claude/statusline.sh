#!/bin/bash
input=$(cat)

# \x1f rather than a tab: bash collapses runs of whitespace IFS characters,
# which would shift fields left whenever an optional value is empty.
IFS=$'\x1f' read -r model used context_size total_tokens dir wt_name wt_original < <(
  echo "$input" | jq -r '[
    .model.display_name // "Unknown",
    .context_window.used_percentage // 0,
    .context_window.context_window_size // 200000,
    .context_window.total_input_tokens // 0,
    .workspace.current_dir // .cwd // "",
    .worktree.name // "",
    .worktree.original_branch // ""
  ] | map(tostring) | join("\u001f")'
)
model=${model:-Unknown}
context_size=${context_size:-200000}

abbrev() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) printf "%gM", int(n / 100000 + 0.5) / 10
    else if (n >= 1000) printf "%dk", int(n / 1000 + 0.5)
    else printf "%d", n
  }'
}

bar_width=20
used_int=$(awk -v u="$used" 'BEGIN { printf "%.0f", u }')
filled=$(( used_int * bar_width / 100 ))
(( filled > bar_width )) && filled=$bar_width

hint=""
if (( used_int < 20 )); then
  color="\033[0;32m"
elif (( used_int < 40 )); then
  color="\033[0;33m"
  hint=" 💡 /clear if switching tasks"
elif (( used_int < 60 )); then
  color="\033[38;5;208m"
  hint=" ⚠️ /compact recommended"
else
  color="\033[0;31m"
  hint=" 🔴 /compact or /clear NOW"
fi
reset="\033[0m"

bar=""
for ((i = 0; i < filled; i++)); do bar+="█"; done
for ((i = filled; i < bar_width; i++)); do bar+="░"; done

printf "%s | ${color}[%s] %s%%%s${reset} | %s/%s tokens\n" \
  "$model" "$bar" "$used_int" "$hint" "$(abbrev "$total_tokens")" "$(abbrev "$context_size")"

branch=$(git -C "${dir:-.}" --no-optional-locks branch --show-current 2>/dev/null)

line2=""
[ -n "$branch" ] && line2="\033[0;36m⎇ ${branch}${reset}"
if [ -n "$wt_name" ]; then
  line2+="${line2:+ }\033[0;35m🌳 ${wt_name}${reset}"
  [ -n "$wt_original" ] && line2+=" \033[2m← ${wt_original}${reset}"
fi
[ -n "$line2" ] && printf '%b\n' "$line2"
exit 0
