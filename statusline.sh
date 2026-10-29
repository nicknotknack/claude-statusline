#!/bin/bash
# model · effort · context · git branch +added −removed      week · session ↻ reset
shopt -s extglob
E=$'\033'

IFS=$'\x1f' read -r model effort ctx week session resets dir < <(jq -r '
  def pct: if . == null then "" else floor end;
  [ .model.display_name // "",
    .effort.level // "",
    (.context_window.used_percentage | pct),
    (.rate_limits.seven_day.used_percentage | pct),
    (.rate_limits.five_hour.used_percentage | pct),
    (.rate_limits.five_hour.resets_at // "" | if . == "" then . else strflocaltime("%H:%M") end),
    .workspace.current_dir // .cwd // ""
  ] | map(tostring) | join("\u001f")')

paint() { printf '%s[%sm%s%s[0m' "$E" "$1" "$2" "$E"; }

# percentage colored by threshold: green < 70, yellow < 90, red otherwise
color_pct() {
  local c=32
  (( $1 >= 70 )) && c=33
  (( $1 >= 90 )) && c=31
  paint "$c" "$1%"
}

parts=("$model")
[ -n "$effort" ] && parts+=("$effort")
# context: green < 40, orange < 60, burgundy < 80, red otherwise
if [ -n "$ctx" ]; then
  c=32
  (( ctx >= 40 )) && c='38;5;208'
  (( ctx >= 60 )) && c='38;5;88'
  (( ctx >= 80 )) && c=31
  parts+=("context: $(paint "$c" "$ctx%")")
else
  parts+=("context: –")
fi

branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
  g=$'\xef\x82\x9b'" $branch"  # nerd font: nf-fa-github
  # " 3 files changed, 10 insertions(+), 2 deletions(-)"
  stat=$(git -C "$dir" --no-optional-locks diff HEAD --shortstat 2>/dev/null)
  [[ $stat =~ ([0-9]+)\ insertion ]] && g+=" $(paint 32 "+${BASH_REMATCH[1]}")"
  [[ $stat =~ ([0-9]+)\ deletion ]] && g+=" $(paint 31 "−${BASH_REMATCH[1]}")"
  parts+=("$g")
fi

right=()
[ -n "$week" ] && right+=("week: $(color_pct "$week")")
if [ -n "$session" ]; then
  s="session: $(color_pct "$session")"
  [ -n "$resets" ] && s+=" ↻ $resets"
  right+=("$s")
fi

join() { local p; out=""; for p in "$@"; do out+="${out:+ · }$p"; done; }
# visible width of $1 without ANSI color codes, in characters
LC_ALL=en_US.UTF-8
width() { local t=${1//$E\[*([0-9;])m/}; w=${#t}; }

join "${parts[@]}"; left=$out
join "${right[@]}"; rside=$out

if [ -z "$rside" ]; then
  printf '%s\n' "$left"
  exit
fi
# push week/session to the right edge; COLUMNS is set by Claude Code, keep a small margin for its padding
width "$left"; gap=$(( ${COLUMNS:-0} - w - 4 ))
width "$rside"; gap=$(( gap - w ))
if (( gap >= 3 )); then
  printf '%s%*s%s\n' "$left" "$gap" '' "$rside"
else
  printf '%s · %s\n' "$left" "$rside"
fi
