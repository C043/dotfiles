#!/usr/bin/env bash

direction="$1"
[ -z "$direction" ] && exit 1

hyprctl dispatch movefocus "$direction"

win=$(hyprctl activewindow -j)
addr=$(echo "$win" | jq -r '.address // empty')

if [ -n "$addr" ] && [ "$addr" != "0x" ]; then
    x=$(echo "$win" | jq '.at[0] // empty')
    y=$(echo "$win" | jq '.at[1] // empty')
    [ -z "$x" ] || [ -z "$y" ] && exit 0
    hyprctl dispatch movecursor $((x + 10)) $((y + 10))
else
    mon=$(hyprctl activeworkspace -j | jq -r '.monitor // empty')
    [ -z "$mon" ] && exit 0
    eval "$(hyprctl monitors -j | jq -r --arg m "$mon" '.[] | select(.name==$m) | "mx=\(.x) my=\(.y) mw=\(.width) mh=\(.height)"')"
    hyprctl dispatch movecursor $((mx + mw / 2)) $((my + mh / 2))
fi
