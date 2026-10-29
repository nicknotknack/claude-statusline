#!/bin/bash
# model · effort · context · git branch +added −removed      week · session · reset time
# Claude Code runs this in the session's current dir and passes session info as JSON on stdin.
# jq and both git calls start in parallel; jq reads git output through --rawfile.
exec jq -r \
  --rawfile branch <(git symbolic-ref --short HEAD 2>/dev/null) \
  --rawfile stat <(git --no-optional-locks diff HEAD --shortstat 2>/dev/null) '
def paint($c): "\u001b[\($c)m\(.)\u001b[0m";
def pct(color): floor as $p | "\($p)%" | paint($p | color);
# context: green < 40, orange < 60, burgundy < 80, red; limits: green < 70, yellow < 90, red
def ctx: if . >= 80 then 31 elif . >= 60 then "38;5;88" elif . >= 40 then "38;5;208" else 32 end;
def lim: if . >= 90 then 31 elif . >= 70 then 33 else 32 end;
# $stat is " 3 files changed, 10 insertions(+), 2 deletions(-)"
def num($w): $stat | capture("(?<n>[0-9]+) \($w)").n;
def width: gsub("\u001b\\[[0-9;]*m"; "") | length;

([ .model.display_name, .effort.level,
   "context: " + ((.context_window.used_percentage | values | pct(ctx)) // "–"),
   ($branch | rtrimstr("\n") | select(. != "")
     | ["\uf09b " + ., ("+" + num("ins") | paint(32)), ("−" + num("del") | paint(31))]
     | join(" "))
 ] | map(values) | join(" · ")) as $left
| ([ (.rate_limits.seven_day.used_percentage | values | "week: " + pct(lim)),
     (.rate_limits.five_hour | select(.used_percentage)
       | ["session: " + (.used_percentage | pct(lim)), (.resets_at | values | "\uf01e " + strflocaltime("%H:%M"))]
       | join(" · "))
   ] | join(" · ")) as $right
# push week/session to the right edge, keep a small margin for Claude Code padding
| (($ENV.COLUMNS | tonumber? // 0) - ($left | width) - ($right | width) - 4) as $gap
| if $right == "" then $left elif $gap >= 3 then $left + " " * $gap + $right else "\($left) · \($right)" end'
