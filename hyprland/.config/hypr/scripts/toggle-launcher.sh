#!/bin/sh

PIDFILE="/tmp/wofi-launcher.pid"

pid=$(cat "$PIDFILE" 2>/dev/null)
if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    rm -f "$PIDFILE"
    exit 0
fi

wofi \
    --show drun \
    --prompt "Launch" \
    --allow-images \
    --insensitive \
    --style "$HOME/.config/hypr/wofi/style.css" &

echo $! > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT
wait
