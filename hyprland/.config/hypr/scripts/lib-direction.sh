#!/usr/bin/env bash
# Shared directional lookup helpers for movefocus-warp.sh / movewindow-warp.sh.
#
# Hyprland's built-in directional search is not usable for this monitor layout:
#   - getWindowInDirection() scans every visible workspace, so a window on a
#     neighbouring monitor can win over the obvious neighbour on the current one;
#   - getMonitorInDirection() only accepts monitors whose edges touch exactly,
#     which fails for HDMI-A-1 (it sits above and between the side monitors).
# These helpers do the geometry themselves so both scripts behave the same way:
# nearest candidate in the requested direction, ties broken by the longest
# overlap on the perpendicular axis.

# window_in_direction <dir> <clients-json> <active-json>
# Prints the address of the nearest window on the active workspace in <dir>.
window_in_direction() {
    local dir="$1" clients="$2" active="$3"
    jq -r \
        --arg dir "$dir" \
        --argjson ws "$(jq '.workspace.id' <<<"$active")" \
        --arg addr "$(jq -r '.address' <<<"$active")" \
        --argjson ax "$(jq '.at[0]' <<<"$active")" \
        --argjson ay "$(jq '.at[1]' <<<"$active")" \
        --argjson aw "$(jq '.size[0]' <<<"$active")" \
        --argjson ah "$(jq '.size[1]' <<<"$active")" '
        [ .[]
          | select(.workspace.id == $ws and .address != $addr and .mapped and (.hidden | not))
          | {address, x: .at[0], y: .at[1], w: .size[0], h: .size[1]} ]
        | map(select(
            if   $dir == "l" then .x + .w <= $ax + 2
            elif $dir == "r" then .x >= $ax + $aw - 2
            elif $dir == "u" then .y + .h <= $ay + 2
            else                  .y >= $ay + $ah - 2 end))
        | map(. + (
            if ($dir == "l" or $dir == "r")
            then {ov: (([$ay + $ah, .y + .h] | min) - ([$ay, .y] | max)),
                  d:  (if $dir == "l" then $ax - .x - .w else .x - $ax - $aw end)}
            else {ov: (([$ax + $aw, .x + .w] | min) - ([$ax, .x] | max)),
                  d:  (if $dir == "u" then $ay - .y - .h else .y - $ay - $ah end)}
            end))
        | map(select(.ov > 0))
        | sort_by(.d, -.ov)
        | first.address // empty
    ' <<<"$clients"
}

# monitor_in_direction <dir> <monitor-id>
# Prints the name of the nearest monitor in <dir> from the given monitor.
# Monitors that overlap on the perpendicular axis win; otherwise the closest one
# is used, so HDMI-A-1 can still be reached from the side monitors.
monitor_in_direction() {
    local dir="$1" id="$2"
    hyprctl monitors -j | jq -r --arg dir "$dir" --argjson id "$id" '
        (.[] | select(.id == $id)) as $c
        | [ .[] | select(.id != $id) ]
        | map(select(
            if   $dir == "l" then .x + .width  <= $c.x + 2
            elif $dir == "r" then .x >= $c.x + $c.width - 2
            elif $dir == "u" then .y + .height <= $c.y + 2
            else                  .y >= $c.y + $c.height - 2 end))
        | map(. + (
            if ($dir == "l" or $dir == "r")
            then {ov: (([$c.y + $c.height, .y + .height] | min) - ([$c.y, .y] | max)),
                  d:  (if $dir == "l" then $c.x - .x - .width else .x - $c.x - $c.width end)}
            else {ov: (([$c.x + $c.width, .x + .width] | min) - ([$c.x, .x] | max)),
                  d:  (if $dir == "u" then $c.y - .y - .height else .y - $c.y - $c.height end)}
            end))
        | sort_by((if .ov > 0 then 0 else 1 end), .d, -.ov)
        | first.name // empty
    '
}

# warp_cursor <window-json>
# Parks the pointer inside the given window, or on its monitor if it is empty.
warp_cursor() {
    local win="$1" x y mon mx my mw mh
    x=$(jq '.at[0] // empty' <<<"$win")
    y=$(jq '.at[1] // empty' <<<"$win")
    if [ -n "$x" ] && [ -n "$y" ]; then
        hyprctl dispatch movecursor $((x + 10)) $((y + 10)) >/dev/null
        return
    fi
    mon=$(hyprctl activeworkspace -j | jq -r '.monitor // empty')
    [ -z "$mon" ] && return
    eval "$(hyprctl monitors -j | jq -r --arg m "$mon" \
        '.[] | select(.name == $m) | "mx=\(.x) my=\(.y) mw=\(.width) mh=\(.height)"')"
    hyprctl dispatch movecursor $((mx + mw / 2)) $((my + mh / 2)) >/dev/null
}
