#!/bin/sh

current_default=$(
    pactl info 2>/dev/null | awk -F': ' '/Default Sink:/ {print $2}'
)

[ -n "$current_default" ] || exit 1

sinks=$(
    pactl list short sinks 2>/dev/null | awk '{print $2}'
)

[ -n "$sinks" ] || exit 1

next_sink=$(
    printf '%s\n' "$sinks" | awk -v current="$current_default" '
        found { print; exit }
        $0 == current { found = 1 }
        END {
            if (!found || NR == 0) {
                exit 1
            }
        }
    '
)

if [ -z "$next_sink" ]; then
    next_sink=$(printf '%s\n' "$sinks" | head -n 1)
fi

[ -n "$next_sink" ] || exit 1

pactl set-default-sink "$next_sink"

pactl list short sink-inputs 2>/dev/null | awk '{print $1}' | while read -r input_id; do
    [ -n "$input_id" ] || continue
    pactl move-sink-input "$input_id" "$next_sink"
done
