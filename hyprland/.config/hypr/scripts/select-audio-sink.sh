#!/bin/sh

if pgrep -af 'wofi.*Audio output' >/dev/null 2>&1; then
    exec pkill -f 'wofi.*Audio output'
fi

default_sink=$(
    pactl info 2>/dev/null | awk -F': ' '/Default Sink:/ {print $2}'
)

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

pactl list sinks 2>/dev/null | awk -F': ' '
    /^\s*Name:/ { name = $2; gsub(/^[ \t]+/, "", name) }
    /^\s*Description:/ { desc = $2; gsub(/^[ \t]+/, "", desc); print name "\t" desc }
' > "$tmpfile"

selection=$(
    awk -F'\t' -v default_sink="$default_sink" '
        { if ($1 == default_sink) def = "Default  " $2; else rest[++n] = $2 }
        END { if (def) print def; for (i = 1; i <= n; i++) print rest[i] }
    ' "$tmpfile" | wofi \
        --dmenu \
        --prompt "Audio output" \
        --insensitive \
        --style "$HOME/.config/hypr/wofi/style.css"
)

[ -n "$selection" ] || exit 0

chosen_desc=${selection#Default  }
sink_name=$(awk -F'\t' -v desc="$chosen_desc" '$2 == desc { print $1; exit }' "$tmpfile")
[ -n "$sink_name" ] || exit 1

pactl set-default-sink "$sink_name"

pactl list short sink-inputs 2>/dev/null | awk '{print $1}' | while read -r input_id; do
    [ -n "$input_id" ] || continue
    pactl move-sink-input "$input_id" "$sink_name"
done
