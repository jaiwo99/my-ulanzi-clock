#!/usr/bin/env bash
set -euo pipefail

# ========= User config =========
AWTRIX_IP="${AWTRIX_IP:-192.168.1.30}"     # <- change to your clock's IP

# ========= Apply settings to AWTRIX clock =========
echo "Applying settings to AWTRIX clock at ${AWTRIX_IP}..."

# Settings payload (each setting explained):
# MATP: Matrix auto brightness enabled
# ABRI: Auto brightness disabled (using fixed BRI value)
# BRI: Brightness level (0-255)
# ATRANS: Auto transition between apps
# TCOL: Text color (16777215 = white)
# TEFF: Transition effect (0=slide)
# TSPEED: Transition speed in milliseconds
# ATIME: App display time in seconds
# TMODE: Time display mode (2=shows time)
# CHCOL: Clock hour color (16711680 = red)
# CTCOL: Clock text color (0 = black)
# CBCOL: Clock background color (16777215 = white)
# TFORMAT: Time format (24-hour)
# DFORMAT: Date format (DD.MM.YY)
# SOM: Start of week Monday (true) or Sunday (false)
# CEL: Celsius temperature scale
# BLOCKN: Block notifications
# MAT: Matrix type (0=default)
# SOUND: Sound enabled
# GAMMA: Gamma correction value
# UPPERCASE: Text in uppercase
# CCORRECTION: Color correction
# CTEMP: Color temperature
# WD: Weekday display enabled
# WDCA: Weekday active color (16777215 = white)
# WDCI: Weekday inactive color (6710886 = gray)
# TIME_COL: Time color (0 = default)
# DATE_COL: Date color (0 = default)
# HUM_COL: Humidity color (0 = default)
# TEMP_COL: Temperature color (0 = default)
# BAT_COL: Battery color (0 = default)
# SSPEED: Scroll speed percentage
# TIM: Show time indicator
# DAT: Show date indicator
# HUM: Show humidity indicator
# TEMP: Show temperature indicator
# BAT: Show battery indicator
# VOL: Volume level (0-100)
# OVERLAY: Overlay mode

settings='{
  "MATP": true,
  "ABRI": false,
  "BRI": 10,
  "ATRANS": true,
  "TCOL": 16777215,
  "TEFF": 0,
  "TSPEED": 400,
  "ATIME": 30,
  "TMODE": 2,
  "CHCOL": 16711680,
  "CTCOL": 0,
  "CBCOL": 16777215,
  "TFORMAT": "%H %M",
  "DFORMAT": "%d.%m.%y",
  "SOM": true,
  "CEL": true,
  "BLOCKN": false,
  "MAT": 0,
  "SOUND": true,
  "GAMMA": 1.899999976,
  "UPPERCASE": true,
  "CCORRECTION": "#000000",
  "CTEMP": "#000000",
  "WD": true,
  "WDCA": 16777215,
  "WDCI": 6710886,
  "TIME_COL": 0,
  "DATE_COL": 0,
  "HUM_COL": 0,
  "TEMP_COL": 0,
  "BAT_COL": 0,
  "SSPEED": 100,
  "TIM": true,
  "DAT": true,
  "HUM": false,
  "TEMP": false,
  "BAT": false,
  "VOL": 25,
  "OVERLAY": "clear"
}'

# Send settings to AWTRIX
curl -fsS -X POST "http://${AWTRIX_IP}/api/settings" \
     -H "Content-Type: application/json" \
     -d "$settings"

echo ""
echo "Settings applied successfully!"
