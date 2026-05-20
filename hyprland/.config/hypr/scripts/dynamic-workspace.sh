#!/usr/bin/env bash
set -euo pipefail

AWS=$(hyprctl activeworkspace -j)
WS=$(hyprctl workspaces -j)
MONITOR=$(jq -r '.monitor' <<< "$AWS")
CURRENT_ID=$(jq -r '.id' <<< "$AWS")

find_free_id() {
    local used id=5
    used=$(jq -r '[.[].id] | sort | .[]' <<< "$WS")
    while grep -qw "$id" <<< "$used"; do
        id=$((id + 1))
    done
    echo "$id"
}

is_last_on_monitor() {
    local last
    last=$(jq -r --arg mon "$MONITOR" \
        '[.[] | select(.monitor == $mon and .id > 0)] | sort_by(.id) | last | .id' <<< "$WS")
    [[ "$CURRENT_ID" == "$last" ]]
}

is_first_on_monitor() {
    local first
    first=$(jq -r --arg mon "$MONITOR" \
        '[.[] | select(.monitor == $mon and .id > 0)] | sort_by(.id) | first | .id' <<< "$WS")
    [[ "$CURRENT_ID" == "$first" ]]
}

case "${1:?Usage: $0 [move-next|move-prev|move-new|move-new-silent]}" in
    move-next)
        if is_last_on_monitor; then
            hyprctl dispatch movetoworkspace "$(find_free_id)"
        else
            hyprctl dispatch movetoworkspace m+1
        fi
        ;;
    move-prev)
        if ! is_first_on_monitor; then
            hyprctl dispatch movetoworkspace m-1
        fi
        ;;
    move-new)
        hyprctl dispatch movetoworkspace "$(find_free_id)"
        ;;
    move-new-silent)
        hyprctl dispatch movetoworkspacesilent "$(find_free_id)"
        ;;
    *)
        echo "Unknown action: $1" >&2
        exit 1
        ;;
esac
