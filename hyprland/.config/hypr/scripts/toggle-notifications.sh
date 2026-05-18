#!/bin/sh

if pgrep -af 'wofi.*Notifications' >/dev/null 2>&1; then
    exec pkill -f 'wofi.*Notifications'
fi

notifications="$(makoctl history 2>/dev/null)"

if [ -z "$notifications" ]; then
    notifications="No notifications"
fi

printf '%s\n' "$notifications" | wofi \
    --dmenu \
    --prompt "Notifications" \
    --lines 12 \
    --width 520 \
    --hide-scroll \
    --style "$HOME/.config/hypr/wofi/calendar.css" >/dev/null
