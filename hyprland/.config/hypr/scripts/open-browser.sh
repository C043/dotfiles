#!/bin/sh

desktop_file=$(xdg-settings get default-web-browser 2>/dev/null)

case "$desktop_file" in
    *.desktop)
        exec gtk-launch "${desktop_file%.desktop}"
        ;;
esac

exec xdg-open about:blank
