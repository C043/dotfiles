#!/usr/bin/env bash

direction="$1"
[ -z "$direction" ] && exit 1

before=$(hyprctl activewindow -j)
before_addr=$(echo "$before" | jq -r '.address // empty')
before_x=$(echo "$before" | jq '.at[0] // 0')
before_y=$(echo "$before" | jq '.at[1] // 0')
before_mon=$(echo "$before" | jq -r '.monitor // empty')

hyprctl dispatch movefocus "$direction"

win=$(hyprctl activewindow -j)
addr=$(echo "$win" | jq -r '.address // empty')
after_x=$(echo "$win" | jq '.at[0] // 0')
after_y=$(echo "$win" | jq '.at[1] // 0')
after_mon=$(echo "$win" | jq -r '.monitor // empty')

# Fallback: if focus stayed on the same monitor and either didn't move or
# wrapped around (moved opposite to intended direction), force-focus the
# target monitor. Hyprland requires Y-overlap for directional focus, which
# fails for the top monitor (HDMI-A-1) trying to reach side monitors.
need_fallback=false
if [ "$after_mon" = "$before_mon" ]; then
    case "$direction" in
        l) [ "$after_x" -ge "$before_x" ] && need_fallback=true ;;
        r) [ "$after_x" -le "$before_x" ] && need_fallback=true ;;
        u) [ "$after_y" -ge "$before_y" ] && need_fallback=true ;;
        d) [ "$after_y" -le "$before_y" ] && need_fallback=true ;;
    esac
fi

if $need_fallback; then
    if [ "$addr" != "$before_addr" ] && [ -n "$before_addr" ] && [ "$before_addr" != "0x" ]; then
        hyprctl dispatch focuswindow "address:$before_addr"
    fi
    case "$direction" in
        l) target="DP-2" ;;
        r) target="DP-1" ;;
        u) target="HDMI-A-1" ;;
        *) target="" ;;
    esac
    if [ -n "$target" ] && [ "$before_mon" != "$target" ]; then
        hyprctl dispatch focusmonitor "$target"
        win=$(hyprctl activewindow -j)
        addr=$(echo "$win" | jq -r '.address // empty')
    fi
fi

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
