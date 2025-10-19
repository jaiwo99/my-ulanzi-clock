#!/usr/bin/env bash
set -euo pipefail

# ========= User config =========
AWTRIX_IP="${AWTRIX_IP:-192.168.1.30}"     # <- change to your clock's IP
APP_NAME="${APP_NAME:-berlin_weather}"     # name of the AWTRIX custom app
ICON_ID="${ICON_ID:-2497}"                     # optional: icon id or filename on the clock, e.g. 50002; leave empty for none
DURATION="${DURATION:-10}"                 # seconds to display when the app is shown
NO_SCROLL="${NO_SCROLL:-true}"             # true keeps the text static if it fits
PUSH_MODE="${PUSH_MODE:-custom}"           # custom | notify

# Berlin coords & timezone (Europe/Berlin)
LAT="${LAT:-52.52}"
LON="${LON:-13.41}"
TZ="${TZ:-Europe/Berlin}"

# ========= Fetch weather =========
OM_URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min&wind_speed_unit=kmh&timezone=${TZ}"
# or, if you prefer auto:
# OM_URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min&wind_speed_unit=kmh&timezone=auto"

#echo "debug"
#curl -fsSL --max-time 10 "$OM_URL" -v


weather_json="$(curl -fsSL --max-time 10 "$OM_URL")"
temp="$(jq -r '.current.temperature_2m' <<<"$weather_json")"
hum="$(jq -r '.current.relative_humidity_2m' <<<"$weather_json")"
wind="$(jq -r '.current.wind_speed_10m' <<<"$weather_json")"
wcode="$(jq -r '.current.weather_code' <<<"$weather_json")"
temp_min="$(jq -r '.daily.temperature_2m_min[0]' <<<"$weather_json")"
temp_max="$(jq -r '.daily.temperature_2m_max[0]' <<<"$weather_json")"

# ========= Map weather code to a short label =========
# Open-Meteo WMO weather_code quick map (minimal set, expand if you like)
case "$wcode" in
  0)  cond="Klar" ;;
  1|2) cond="Wolkig" ;;
  3)  cond="Bedeckt" ;;
  45|48) cond="Nebel" ;;
  51|53|55) cond="Niesel" ;;
  61|63|65) cond="Regen" ;;
  66|67) cond="Gefr. Regen" ;;
  71|73|75|77) cond="Schnee" ;;
  80|81|82) cond="Schauer" ;;
  85|86) cond="Schneeschauer" ;;
  95) cond="Gewitter" ;;
  96|99) cond="Gew. Hagel" ;;
  *) cond="Wetter" ;;
esac

# Compose a compact single-line text for 32x8 px
#text="$(printf '%s · %.0f°C · %s%% · %.0f km/h' "$cond" "$temp" "$hum" "$wind")"
#text="$(printf '%.0f°C' "$temp")"
text="$(printf '%.0f-%.0f°C' "$temp_min" "$temp_max")"

echo $text

# ========= Build AWTRIX payload =========
# See AWTRIX 3 API: /api/custom?name=... (persistent) or /api/notify (one-shot)
payload_base="$(jq -n \
  --arg text "$text" \
  --argjson duration "$DURATION" \
  --argjson noScroll "$( [ "$NO_SCROLL" = "true" ] && echo true || echo false )" \
  '{text:$text, rainbow:true, duration:$duration, noScroll:$noScroll}')"

# Add icon only if provided
if [[ -n "$ICON_ID" ]]; then
  payload="$(jq --arg icon "$ICON_ID" '. + {icon:$icon}' <<<"$payload_base")"
else
  payload="$payload_base"
fi

# ========= Push to AWTRIX =========
if [[ "$PUSH_MODE" = "notify" ]]; then
  # one-shot notification (stacks temporarily on top of the loop)
  curl -fsS -X POST "http://${AWTRIX_IP}/api/notify" \
       -H "Content-Type: application/json" \
       -d "$payload" >/dev/null
else
  # persistent custom app that lives in the app loop
  curl -fsS -X POST "http://${AWTRIX_IP}/api/custom?name=${APP_NAME}" \
       -H "Content-Type: application/json" \
       -d "$payload" >/dev/null
fi
