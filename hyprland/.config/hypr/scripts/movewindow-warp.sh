#!/usr/bin/env bash
# Move the focused window one step in a direction, then warp the pointer to it.
#
# Hyprland's own `movewindow <dir>` cannot be used directly:
#   - under dwindle it is a no-op whenever the target is the window's direct
#     sibling, because it removes the node and re-inserts it in the very same
#     spot, so two side-by-side windows never trade places;
#   - its monitor fallback only fires when no window at all is found in that
#     direction, and this layout's monitors overlap vertically, so a window on
#     the neighbouring monitor is always found and the move is dropped.
# So the direction search happens here: swap with the neighbour inside the
# monitor, and hand the window to the neighbouring monitor when there is none.

source "$(dirname "$0")/lib-direction.sh"

direction="$1"
mode="${2:-movewindoworgroup}"
[ -z "$direction" ] && exit 1

win=$(hyprctl activewindow -j)
addr=$(echo "$win" | jq -r '.address // empty')
[ -z "$addr" ] || [ "$addr" = "0x" ] && exit 0

mon=$(echo "$win" | jq '.monitor')
before_at=$(echo "$win" | jq -c '.at')

# Floating windows are nudged by Hyprland itself, no layout tree involved.
if [ "$(echo "$win" | jq -r '.floating')" = "true" ]; then
    hyprctl dispatch movewindow "$direction" >/dev/null
    warp_cursor "$(hyprctl activewindow -j)"
    exit 0
fi

clients=$(hyprctl clients -j)
target=$(window_in_direction "$direction" "$clients" "$win")

if [ -n "$target" ]; then
    in_group=$(echo "$win" | jq -r 'if (.grouped | length) > 0 then "yes" else "no" end')
    target_group=$(echo "$clients" | jq -r --arg a "$target" \
        '.[] | select(.address == $a) | if (.grouped | length) > 0 then "yes" else "no" end')
    # movewindoworgroup is only interesting when a group is involved: it merges
    # into the neighbouring group, or pops the window out of its own one.
    if [ "$mode" = "movewindoworgroup" ] && { [ "$in_group" = "yes" ] || [ "$target_group" = "yes" ]; }; then
        hyprctl dispatch movewindoworgroup "$direction" >/dev/null
    else
        hyprctl dispatch swapwindow "$direction" >/dev/null
    fi
fi

win=$(hyprctl activewindow -j)

# Nothing in the way, or the swap turned out to be a no-op: cross monitors.
if [ "$(echo "$win" | jq -c '.at')" = "$before_at" ]; then
    target_mon=$(monitor_in_direction "$direction" "$mon")
    if [ -n "$target_mon" ]; then
        hyprctl dispatch movewindow "mon:$target_mon" >/dev/null
        win=$(hyprctl activewindow -j)
    fi
fi

warp_cursor "$win"
