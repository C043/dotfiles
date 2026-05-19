#!/usr/bin/env bash

direction="$1"
[ -z "$direction" ] && exit 1

hyprctl dispatch movefocus "$direction"

win=$(hyprctl activewindow -j)
[ -z "$win" ] && exit 0

x=$(echo "$win" | jq '.at[0] // empty')
y=$(echo "$win" | jq '.at[1] // empty')
[ -z "$x" ] || [ -z "$y" ] && exit 0

hyprctl dispatch movecursor $((x + 10)) $((y + 10))
