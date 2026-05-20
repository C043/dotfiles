#!/bin/sh

if pgrep -af 'wofi.*Settings' >/dev/null 2>&1; then
    exec pkill -f 'wofi.*Settings'
fi

choice="$(printf '%s\n' \
    "󰍹  Displays" \
    "󰖩  Network" \
    "󰕾  Audio" \
    "󰂯  Bluetooth" \
    | wofi \
    --dmenu \
    --prompt "Settings" \
    --lines 4 \
    --width 380 \
    --hide-scroll \
    --insensitive \
    --style "$HOME/.config/hypr/wofi/style.css")"

case "$choice" in
    *Displays*) exec nwg-displays ;;
    *Network*) exec nm-connection-editor ;;
    *Audio*) exec pavucontrol ;;
    *Bluetooth*) exec blueman-manager ;;
esac
