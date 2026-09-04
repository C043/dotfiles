#!/usr/bin/env bash
# Fade the screen to black with a screen shader, then lock, then hold the black
# screen until fade-resume.sh kills this script.
#
# The blackout is deliberately *only* a shader: `hyprctl dispatch dpms off`
# disconnects every wayland client on this setup (see hypridle.conf). The EXIT
# trap is what makes the shader safe -- however this script dies, the screen
# comes back, so a stuck shader can never leave a black screen behind.

SHADER_FILE=/tmp/hypr-fade-step.frag
PIDFILE=/tmp/hypr-fade.pid

# Already locked (manual lock): no animation to run, hyprlock is what is on
# screen -- go straight to holding it black.
if pidof hyprlock > /dev/null; then
    ALREADY_LOCKED=1
else
    ALREADY_LOCKED=0
fi

cleanup() {
    hyprctl keyword decoration:screen_shader "[[EMPTY]]" > /dev/null 2>&1
    rm -f "$PIDFILE" "$SHADER_FILE"
}
trap cleanup EXIT INT TERM

echo $$ > "$PIDFILE"

first_step=1
[ "$ALREADY_LOCKED" = 1 ] && first_step=25

for i in $(seq "$first_step" 25); do
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

[ "$ALREADY_LOCKED" = 1 ] || loginctl lock-session

# Stay alive holding the black screen: fade-resume.sh kills this process on the
# next input, and the trap above clears the shader on the way out.
while :; do
    sleep 60
done
