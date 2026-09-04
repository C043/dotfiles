#!/usr/bin/env bash
# Waybar's Hyprland IPC does not retry: if it connects before Hyprland has
# created its event socket, the workspaces module stays dead for the whole
# session (no active highlight, no newly created workspaces). Wait for the
# socket before launching.
set -euo pipefail

SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

for _ in {1..100}; do
    [[ -S "$SOCKET" ]] && break
    sleep 0.1
done

exec waybar \
    -c "$HOME/.config/hypr/waybar/config.jsonc" \
    -s "$HOME/.config/hypr/waybar/style.css"
