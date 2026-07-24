#!/usr/bin/env bash

APP="$1"

if hyprctl clients | grep -q "class: $APP"; then
	hyprctl eval "hl.dispatch(hl.dsp.focus({ window = \"class:$APP\" }))"
else
	"$APP" &
fi
