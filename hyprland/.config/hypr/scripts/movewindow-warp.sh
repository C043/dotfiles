#!/usr/bin/env bash

direction="$1"
mode="${2:-movewindoworgroup}"
[ -z "$direction" ] && exit 1

before_mon=$(hyprctl activewindow -j | jq '.monitor')

hyprctl dispatch "$mode" "$direction"

win=$(hyprctl activewindow -j)
after_mon=$(echo "$win" | jq '.monitor')

if [ "$before_mon" = "$after_mon" ]; then
    target=$(hyprctl monitors -j | jq -r --argjson m "$before_mon" --arg dir "$direction" '
      (.[] | select(.id == $m)) as $c |
      [.[] | select(.id != $m) |
        if $dir == "l" then select(.x + .width <= $c.x)
        elif $dir == "r" then select(.x >= $c.x + $c.width)
        elif $dir == "u" then select(.y + .height <= $c.y)
        else select(.y >= $c.y + $c.height) end
      ] as $candidates |
      [$candidates[] |
        if ($dir == "l" or $dir == "r")
        then select(.y < $c.y + $c.height and .y + .height > $c.y)
        else select(.x < $c.x + $c.width and .x + .width > $c.x) end
      ] as $overlapping |
      if ($overlapping | length) > 0 then empty
      else [$candidates[] |
        if ($dir == "l" or $dir == "r")
        then {name, d: (if $dir == "l" then $c.x - .x - .width else .x - $c.x - $c.width end)}
        else {name, d: (if $dir == "u" then $c.y - .y - .height else .y - $c.y - $c.height end)} end
      ] | sort_by(.d) | first.name end // empty
    ')
    if [ -n "$target" ]; then
        hyprctl dispatch movewindow "mon:$target"
        win=$(hyprctl activewindow -j)
    fi
fi

addr=$(echo "$win" | jq -r '.address // empty')
if [ -n "$addr" ] && [ "$addr" != "0x" ]; then
    x=$(echo "$win" | jq '.at[0] // empty')
    y=$(echo "$win" | jq '.at[1] // empty')
    [ -z "$x" ] || [ -z "$y" ] && exit 0
    hyprctl dispatch movecursor $((x + 10)) $((y + 10))
fi
