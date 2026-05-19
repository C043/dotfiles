#!/bin/sh

if pgrep -af 'wofi.*Audio input' >/dev/null 2>&1; then
    exec pkill -f 'wofi.*Audio input'
fi

default_source=$(
    pactl info 2>/dev/null | awk -F': ' '/Default Source:/ {print $2}'
)

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

pactl list sources 2>/dev/null | awk -F': ' '
    /^\s*Name:/ { name = $2; gsub(/^[ \t]+/, "", name) }
    /^\s*Description:/ {
        desc = $2; gsub(/^[ \t]+/, "", desc)
        if (name !~ /\.monitor$/) print name "\t" desc
    }
' > "$tmpfile"

selection=$(
    awk -F'\t' -v default_source="$default_source" '
        { if ($1 == default_source) def = "Default  " $2; else rest[++n] = $2 }
        END { if (def) print def; for (i = 1; i <= n; i++) print rest[i] }
    ' "$tmpfile" | wofi \
        --dmenu \
        --prompt "Audio input" \
        --insensitive \
        --style "$HOME/.config/hypr/wofi/style.css"
)

[ -n "$selection" ] || exit 0

chosen_desc=${selection#Default  }
source_name=$(awk -F'\t' -v desc="$chosen_desc" '$2 == desc { print $1; exit }' "$tmpfile")
[ -n "$source_name" ] || exit 1

pactl set-default-source "$source_name"
