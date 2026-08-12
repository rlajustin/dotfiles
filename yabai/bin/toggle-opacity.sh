#!/usr/bin/env sh

YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"

opacity_enabled=$($YABAI_BIN -m config window_opacity) || exit 1

if [ "$opacity_enabled" = "off" ]; then
  # State 1 -> 2: dim only unfocused windows.
  "$YABAI_BIN" -m config window_opacity_duration 0.2
  "$YABAI_BIN" -m config active_window_opacity 1.0
  "$YABAI_BIN" -m config normal_window_opacity 0.8
  "$YABAI_BIN" -m config window_opacity on
else
  active_opacity=$($YABAI_BIN -m config active_window_opacity) || exit 1
  if /usr/bin/awk -v opacity="$active_opacity" 'BEGIN { exit !(opacity >= 0.99) }'; then
    # State 2 -> 3: dim focused and unfocused windows equally.
    "$YABAI_BIN" -m config active_window_opacity 0.8
  else
    # State 3 -> 1: restore native opacity for every window.
    "$YABAI_BIN" -m config window_opacity off
  fi
fi

/opt/homebrew/bin/sketchybar --trigger yabai_mode_changed >/dev/null 2>&1 || true
