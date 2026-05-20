#!/usr/bin/env bash
kill "$(cat /tmp/hypr-fade.pid 2>/dev/null)" 2>/dev/null
hyprctl keyword decoration:screen_shader ""
rm -f /tmp/hypr-fade.pid /tmp/hypr-fade-step.frag
