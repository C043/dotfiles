#!/bin/sh

if pgrep -af 'wofi.*Audio output' >/dev/null 2>&1; then
    exec pkill -f 'wofi.*Audio output'
fi

default_sink=$(
    pactl info 2>/dev/null | awk -F': ' '/Default Sink:/ {print $2}'
)

selection=$(
    pactl list short sinks 2>/dev/null | while IFS="$(printf '\t')" read -r sink_id sink_name _; do
        [ -n "$sink_id" ] || continue
        [ -n "$sink_name" ] || continue
        description=$(pactl list sinks 2>/dev/null | awk -v sink="$sink_name" '
            $1 == "Name:" && $2 == sink { in_sink = 1; next }
            in_sink && $1 == "Description:" {
                sub(/^Description: /, "")
                print
                exit
            }
            $1 == "Name:" && $2 != sink { in_sink = 0 }
        ')
        [ -n "$description" ] || description="$sink_name"
        if [ "$sink_name" = "$default_sink" ]; then
            printf 'Default  %s :: %s\n' "$description" "$sink_name"
        else
            printf '%s :: %s\n' "$description" "$sink_name"
        fi
    done | wofi \
        --dmenu \
        --prompt "Audio output" \
        --insensitive \
        --style "$HOME/.config/hypr/wofi/style.css"
)

[ -n "$selection" ] || exit 0

sink_name=${selection##* :: }
[ -n "$sink_name" ] || exit 1

pactl set-default-sink "$sink_name"

pactl list short sink-inputs 2>/dev/null | awk '{print $1}' | while read -r input_id; do
    [ -n "$input_id" ] || continue
    pactl move-sink-input "$input_id" "$sink_name"
done
