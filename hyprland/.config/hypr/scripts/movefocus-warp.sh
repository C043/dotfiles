#!/usr/bin/env bash
# Move focus one step in a direction, then warp the pointer to whatever got it.
#
# Hyprland's `movefocus <dir>` searches every visible workspace at once, so a
# window on a neighbouring monitor can beat the obvious neighbour on the current
# one, and its monitor fallback needs monitors whose edges touch exactly, which
# HDMI-A-1 does not. The direction search is done here instead, matching
# movewindow-warp.sh: nearest window on this workspace, else nearest monitor.

source "$(dirname "$0")/lib-direction.sh"

direction="$1"
[ -z "$direction" ] && exit 1

win=$(hyprctl activewindow -j)
addr=$(echo "$win" | jq -r '.address // empty')

if [ -n "$addr" ] && [ "$addr" != "0x" ]; then
    target=$(window_in_direction "$direction" "$(hyprctl clients -j)" "$win")
    mon=$(echo "$win" | jq '.monitor')
else
    # Empty workspace: nothing to compare against, only the monitor matters.
    target=""
    mon=$(hyprctl monitors -j | jq '.[] | select(.focused) | .id')
fi

if [ -n "$target" ]; then
    hyprctl dispatch focuswindow "address:$target" >/dev/null
else
    target_mon=$(monitor_in_direction "$direction" "$mon")
    [ -n "$target_mon" ] && hyprctl dispatch focusmonitor "$target_mon" >/dev/null
fi

warp_cursor "$(hyprctl activewindow -j)"
