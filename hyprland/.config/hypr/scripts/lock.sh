#!/usr/bin/env bash
# Single owner of hyprlock: hypridle's lock_cmd, which is the only thing that
# reacts to `loginctl lock-session`.
#
# hyprlock aborts on its own in a few situations -- outputs disappearing under
# it (dpms off, monitor hotplug), or never getting the `locked` event because
# the screen was already powered down when it started ("Unlock called, but not
# locked yet. This can happen when dpms is off during the grace period."). When
# that happens Hyprland keeps the ext-session-lock engaged and paints its
# "lockscreen crashed, go find a TTY" screen. Respawning here is what makes the
# session recover by itself instead.
set -u

MAX_ATTEMPTS=10
LOCKFILE=/tmp/hypr-lock.lock

# One supervisor at a time: a second hyprlock is refused by the compositor
# ("Is another lockscreen running?") and would kill this one.
exec 9> "$LOCKFILE"
flock -n 9 || exit 0

for _ in $(seq "$MAX_ATTEMPTS"); do
    pidof hyprlock > /dev/null && exit 0

    # hyprlock cannot come up on outputs that are powered down, so make sure
    # they are awake before every attempt.
    hyprctl dispatch dpms on > /dev/null 2>&1

    # Exit 0 means the password was accepted (or SIGUSR1 unlocked it).
    hyprlock && exit 0

    sleep 1
done
