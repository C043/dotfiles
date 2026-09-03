#!/usr/bin/env bash
# Fade the screen to black, lock, then power the outputs off.
#
# The screen shader is only ever a transient animation. dpms off is the real
# "screen is off" state, and the EXIT trap guarantees the shader is cleared no
# matter how this script dies -- a stuck shader leaves the session on a black
# screen that input cannot recover.

SHADER_FILE=/tmp/hypr-fade-step.frag
PIDFILE=/tmp/hypr-fade.pid

cleanup() {
    hyprctl keyword decoration:screen_shader "[[EMPTY]]" > /dev/null 2>&1
    rm -f "$PIDFILE" "$SHADER_FILE"
}
trap cleanup EXIT INT TERM

echo $$ > "$PIDFILE"

for i in $(seq 1 25); do
    pct=$((i * 4))
    if [ $pct -ge 100 ]; then
        alpha="1.0"
    else
        alpha="0.$(printf '%02d' $pct)"
    fi
    cat > "$SHADER_FILE" << SHADER
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    gl_FragColor = mix(color, vec4(0.0, 0.0, 0.0, 1.0), ${alpha});
}
SHADER
    hyprctl keyword decoration:screen_shader "$SHADER_FILE" > /dev/null 2>&1
    sleep 0.2
done

loginctl lock-session

# Let hyprlock map its surface behind the black shader, then hand over to dpms.
# If hyprlock failed to start, this still ends in a recoverable state: the
# outputs are merely asleep and any input turns them back on.
sleep 1
hyprctl keyword decoration:screen_shader "[[EMPTY]]" > /dev/null 2>&1
hyprctl dispatch dpms off
