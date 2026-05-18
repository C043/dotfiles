#!/bin/sh

if pgrep -x wofi >/dev/null 2>&1; then
    exec pkill -x wofi
fi

exec wofi \
    --show drun \
    --prompt "Launch" \
    --allow-images \
    --insensitive \
    --style /home/c043/.config/hypr/wofi/style.css
