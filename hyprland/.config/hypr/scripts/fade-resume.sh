#!/usr/bin/env bash
# Undo fade-to-black.sh. Power comes back first: dpms on is safe to run
# unconditionally and is what actually makes the screen visible again.
#
# This is the only way out of the blackout, so it never trusts a single
# mechanism: it kills by pidfile *and* by name, waits for the process to really
# be gone (it re-applies the shader every 0.2s, so clearing the shader while it
# still runs is a no-op), escalates to SIGKILL, and clears the shader either way.
set -u

# Match the script by name, not by the path hypridle happens to use: an
# orphan started from a different cwd or via `sh -c` must die too. Anchored
# at the end so it only ever matches a shell *running* the script, never
# some other command that merely mentions its path.
FADE='(ba)?sh .*fade-to-black\.sh$'
PIDFILE="$XDG_RUNTIME_DIR/hypr-fade.pid"
SHADER_FILE="$XDG_RUNTIME_DIR/hypr-fade-step.frag"

# hypridle runs this after every pause of a second or more (see hypridle.conf),
# so bail out cheaply unless something of the fade is actually left: its
# pidfile, its process, or its shader still applied.
if [ ! -e "$PIDFILE" ] && ! pgrep -f "$FADE" > /dev/null 2>&1 \
    && ! hyprctl getoption decoration:screen_shader 2>/dev/null | grep -qF "str: $SHADER_FILE"; then
    exit 0
fi

hyprctl dispatch dpms on > /dev/null 2>&1

kill "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null
pkill -f "$FADE" 2>/dev/null

for _ in $(seq 20); do
    pgrep -f "$FADE" > /dev/null 2>&1 || break
    sleep 0.1
done
pkill -KILL -f "$FADE" 2>/dev/null

# "" is parsed as a shader path by Hyprland; [[EMPTY]] is the reset value
hyprctl keyword decoration:screen_shader "[[EMPTY]]" > /dev/null 2>&1
rm -f "$PIDFILE" "$SHADER_FILE"
