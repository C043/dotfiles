#!/usr/bin/env bash
kill "$(cat /tmp/hypr-fade.pid 2>/dev/null)" 2>/dev/null
# let the fade loop finish its in-flight `sleep 0.2` and exit, so it cannot
# re-apply the shader after we clear it below
sleep 0.3
# "" is parsed as a shader path by Hyprland; [[EMPTY]] is the reset value
hyprctl keyword decoration:screen_shader "[[EMPTY]]"
rm -f /tmp/hypr-fade.pid /tmp/hypr-fade-step.frag
