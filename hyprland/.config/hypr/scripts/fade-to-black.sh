#!/usr/bin/env bash
echo $$ > /tmp/hypr-fade.pid
for i in $(seq 1 25); do
    pct=$((i * 4))
    if [ $pct -ge 100 ]; then
        alpha="1.0"
    else
        alpha="0.$(printf '%02d' $pct)"
    fi
    cat > /tmp/hypr-fade-step.frag << SHADER
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    gl_FragColor = mix(color, vec4(0.0, 0.0, 0.0, 1.0), ${alpha});
}
SHADER
    hyprctl keyword decoration:screen_shader /tmp/hypr-fade-step.frag > /dev/null 2>&1
    sleep 0.2
done
sleep 5
loginctl lock-session
