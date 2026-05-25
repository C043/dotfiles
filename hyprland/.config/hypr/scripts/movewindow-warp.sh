#!/usr/bin/env bash

direction="$1"
mode="${2:-movewindoworgroup}"
[ -z "$direction" ] && exit 1

before=$(hyprctl activewindow -j)
before_mon=$(echo "$before" | jq -r '.monitor // empty')
before_x=$(echo "$before" | jq '.at[0] // empty')
before_y=$(echo "$before" | jq '.at[1] // empty')

hyprctl dispatch "$mode" "$direction"

win=$(hyprctl activewindow -j)
after_mon=$(echo "$win" | jq -r '.monitor // empty')
after_x=$(echo "$win" | jq '.at[0] // empty')
after_y=$(echo "$win" | jq '.at[1] // empty')

# Fallback: if window didn't move cross-monitor, force it to the target monitor.
# Needed because Hyprland requires Y-overlap for directional moves, which fails
# for the top monitor and the bottom portion of the taller central monitor.
if [ "$before_mon" = "$after_mon" ] && [ "$before_x" = "$after_x" ] && [ "$before_y" = "$after_y" ]; then
    case "$direction" in
        l) target="DP-2" ;;
        r) target="DP-1" ;;
        u) target="HDMI-A-1" ;;
        *) target="" ;;
    esac
    if [ -n "$target" ] && [ "$after_mon" != "$target" ]; then
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
