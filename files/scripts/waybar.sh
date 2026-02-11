#!/usr/bin/env bash

if ps -e | grep "[w]aybar"; then
    pkill waybar
else
    waybar --config ~/.config/waybar/config.jsonc --style ~/.config/waybar/style.css &
fi
