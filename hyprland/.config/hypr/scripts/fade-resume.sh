#!/usr/bin/env bash
# Undo fade-to-black.sh. Power comes back first: dpms on is safe to run
# unconditionally and is what actually makes the screen visible again.
hyprctl dispatch dpms on

kill "$(cat /tmp/hypr-fade.pid 2>/dev/null)" 2>/dev/null
# The fade loop's EXIT trap clears the shader, but only once its in-flight
# `sleep 0.2` returns; clear it here too in case the kill missed entirely.
sleep 0.3
# "" is parsed as a shader path by Hyprland; [[EMPTY]] is the reset value
hyprctl keyword decoration:screen_shader "[[EMPTY]]"
rm -f /tmp/hypr-fade.pid /tmp/hypr-fade-step.frag
