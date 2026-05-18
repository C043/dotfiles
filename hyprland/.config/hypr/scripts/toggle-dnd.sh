#!/bin/sh

makoctl mode -t do-not-disturb
pkill -RTMIN+1 waybar
