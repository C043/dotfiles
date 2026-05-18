#!/bin/sh

if pgrep -af 'wofi.*Power' >/dev/null 2>&1; then
    exec pkill -f 'wofi.*Power'
fi

choice="$(printf '%s\n' "Lock" "Logout" "Reboot" "Shutdown" | wofi \
    --dmenu \
    --prompt "Power" \
    --lines 4 \
    --width 320 \
    --hide-scroll \
    --style "$HOME/.config/hypr/wofi/calendar.css")"

case "$choice" in
    Lock)
        exec hyprlock
        ;;
    Logout)
        exec hyprctl dispatch exit
        ;;
    Reboot)
        exec systemctl reboot
        ;;
    Shutdown)
        exec systemctl poweroff
        ;;
esac
