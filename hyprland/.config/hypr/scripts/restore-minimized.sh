#!/bin/sh

clients=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:minimized") | "\(.address)\t\(.class): \(.title)"')

[ -z "$clients" ] && exit 0

chosen=$(echo "$clients" | cut -f2 | wofi \
    --show dmenu \
    --prompt "Restore" \
    --insensitive \
    --style "$HOME/.config/hypr/wofi/style.css")

[ -z "$chosen" ] && exit 0

address=$(echo "$clients" | grep -F "$chosen" | head -1 | cut -f1)

hyprctl --batch "dispatch movetoworkspacesilent e+0,address:$address ; dispatch focuswindow address:$address"
