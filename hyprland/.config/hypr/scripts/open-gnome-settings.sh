#!/bin/sh

panel="$1"

if [ -n "$panel" ]; then
    exec env XDG_CURRENT_DESKTOP=GNOME XDG_SESSION_DESKTOP=gnome gnome-control-center "$panel"
fi

exec env XDG_CURRENT_DESKTOP=GNOME XDG_SESSION_DESKTOP=gnome gnome-control-center
