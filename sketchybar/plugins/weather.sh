#!/usr/bin/env bash

ENV_FILE="$CONFIG_DIR/sketchybar_env"
if [ -r "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

if [ -z "${API_KEY:-}" ]; then
  sketchybar --set weather icon="󰖐" label="--°"
  exit 0
fi

# Explicit LAT/LON values in sketchybar_env take priority. Otherwise use an
# approximate, IP-derived location without sending the OpenWeather key there.
if [ -z "${LAT:-}" ] || [ -z "${LON:-}" ]; then
  LOCATION_DATA="$(/usr/bin/curl -fsS --max-time 8 https://ipapi.co/json/ 2>/dev/null || true)"
  LAT="$(printf '%s' "$LOCATION_DATA" | /usr/bin/jq -r '.latitude // empty')"
  LON="$(printf '%s' "$LOCATION_DATA" | /usr/bin/jq -r '.longitude // empty')"
fi

if [ -z "${LAT:-}" ] || [ -z "${LON:-}" ]; then
  sketchybar --set weather icon="󰖐" label="--°"
  exit 0
fi

URL="https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&appid=${API_KEY}&units=metric"
DATA="$(/usr/bin/curl -fsS --max-time 8 "$URL" 2>/dev/null || true)"

TEMP="$(printf '%s' "$DATA" | /usr/bin/jq -r '.main.temp // empty' | /usr/bin/awk '{printf "%.0f", $1}')"
CONDITION="$(printf '%s' "$DATA" | /usr/bin/jq -r '.weather[0].main // empty')"

case "$CONDITION" in
  Thunderstorm) ICON="󰙾" ;;
  Drizzle|Rain) ICON="󰖗" ;;
  Snow) ICON="󰖘" ;;
  Clear) ICON="󰖙" ;;
  Clouds) ICON="󰖐" ;;
  Mist|Fog|Haze|Smoke|Dust|Ash|Sand) ICON="󰖑" ;;
  *) ICON="󰖐" ;;
esac

if [ -z "$TEMP" ]; then
  sketchybar --set weather icon="$ICON" label="--°"
else
  sketchybar --animate tanh 10 --set weather icon="$ICON" label="${TEMP}°C"
fi
