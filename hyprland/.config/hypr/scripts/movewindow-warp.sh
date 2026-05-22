#!/usr/bin/env bash

direction="$1"
mode="${2:-movewindoworgroup}"
[ -z "$direction" ] && exit 1

hyprctl dispatch "$mode" "$direction"

win=$(hyprctl activewindow -j)
addr=$(echo "$win" | jq -r '.address // empty')

if [ -n "$addr" ] && [ "$addr" != "0x" ]; then
    x=$(echo "$win" | jq '.at[0] // empty')
    y=$(echo "$win" | jq '.at[1] // empty')
    [ -z "$x" ] || [ -z "$y" ] && exit 0
    hyprctl dispatch movecursor $((x + 10)) $((y + 10))
fi
