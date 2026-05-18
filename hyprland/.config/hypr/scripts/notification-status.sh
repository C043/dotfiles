#!/bin/sh

if makoctl mode 2>/dev/null | grep -q do-not-disturb; then
    echo '{"text": "󰂛", "tooltip": "Do Not Disturb", "class": "dnd"}'
else
    echo '{"text": "󰂚", "tooltip": "Notifications", "class": "enabled"}'
fi
