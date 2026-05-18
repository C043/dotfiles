#!/bin/sh

if command -v waycal >/dev/null 2>&1; then
    if pgrep -x waycal >/dev/null 2>&1; then
        exec pkill -x waycal
    fi

    exec waycal
fi

if pgrep -x gnome-calendar >/dev/null 2>&1; then
    exec pkill -x gnome-calendar
fi

exec gnome-calendar
