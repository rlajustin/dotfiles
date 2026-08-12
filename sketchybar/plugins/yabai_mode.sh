#!/bin/sh

source "$CONFIG_DIR/colors.sh"

case "$NAME" in
  yabai_layout)
    layout=$(/opt/homebrew/bin/yabai -m query --spaces --space 2>/dev/null | /usr/bin/jq -r '.type // empty')
    case "$layout" in
      bsp)   label="bsp" ;;
      stack) label="stack" ;;
      float) label="float" ;;
      *)     label="—" ;;
    esac
    opacity=$(/opt/homebrew/bin/yabai -m config window_opacity 2>/dev/null)
    if [ "$opacity" = "on" ]; then
      active_opacity=$(/opt/homebrew/bin/yabai -m config active_window_opacity 2>/dev/null)
      if /usr/bin/awk -v opacity="$active_opacity" 'BEGIN { exit !(opacity >= 0.99) }'; then
        badge="◐"
      else
        badge="●"
      fi
    else
      badge="○"
    fi
    ;;
  *)
    exit 0
    ;;
esac

/opt/homebrew/bin/sketchybar --animate tanh 10 --set "$NAME" \
  icon="$label" \
  icon.color="$COLOR_TEXT" \
  icon.padding_right=0 \
  label="$badge" \
  label.color="$COLOR_ROSE" \
  label.drawing=on
