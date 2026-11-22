#!/bin/sh
set -e
install -m 755 "$(dirname "$0")/case-fan-control.py" /usr/local/bin/case-fan-control
sed -i 's/^User=nobody$/DynamicUser=yes/' /etc/systemd/system/case-fan-control.service
systemctl daemon-reload
systemctl restart case-fan-control
sleep 2; systemctl --no-pager status case-fan-control | head -8
