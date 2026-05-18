#!/bin/sh

if pgrep -af 'wofi.*Notifications' >/dev/null 2>&1; then
    exec pkill -f 'wofi.*Notifications'
fi

notifications="$(makoctl list 2>/dev/null)"

menu="$(printf '%s\n' \
    'Clear all notifications' \
    '---' \
    "${notifications:-No notifications}")"

selection="$(printf '%s\n' "$menu" | wofi \
    --dmenu \
    --prompt "Notifications" \
    --lines 12 \
    --width 520 \
    --hide-scroll \
    --style "$HOME/.config/hypr/wofi/calendar.css")"

if [ "$selection" = 'Clear all notifications' ]; then
    makoctl dismiss --all --no-history
fi
