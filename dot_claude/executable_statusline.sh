#!/usr/bin/env bash
input=$(cat)

# One jq pass, one field per line (order must match the mapfile indices below).
mapfile -t f < <(printf '%s' "$input" | jq -r '
  def pct: if . == null then "-" else "\(round)%" end;
  (.model.display_name // "Claude"),
  (.effort.level // "-"),
  (.workspace.current_dir // "-"),
  (.session_name // "-"),
  (.context_window.used_percentage | pct),
  (.rate_limits.five_hour.used_percentage | pct),
  (.rate_limits.seven_day.used_percentage | pct)')

model=${f[0]:-Claude} effort=${f[1]:--} dir=${f[2]:--} session=${f[3]:--}
ctx=${f[4]:--} h5=${f[5]:--} d7=${f[6]:--}

printf '%s' "$model"
[ "$effort" != "-" ] && printf ' [%s]' "$effort"
printf ' %s' "$dir"
[ "$session" != "-" ] && printf ' (%s)' "$session"
printf ' ctx:%s 5h:%s 7d:%s' "$ctx" "$h5" "$d7"
printf '\n'
