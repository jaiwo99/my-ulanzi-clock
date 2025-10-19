# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains Bash scripts for managing an AWTRIX 3 LED pixel clock:
- `berlin-weather.sh`: Fetches weather data for Berlin and displays it on the clock
- `clock-sleep-wake.sh`: Controls the clock's power state (sleep/wake)
- `clock-settings.sh`: Applies predefined configuration settings to the clock

## Architecture

**Single Script Design**: The entire application is a standalone Bash script (`berlin-weather.sh`) with no external dependencies beyond standard Unix utilities (`curl`, `jq`, `bash`).

**Data Flow**:
1. Fetch current weather from Open-Meteo API (temperature, humidity, wind speed, weather code)
2. Map WMO weather codes to German condition labels (e.g., "Klar", "Regen", "Gewitter")
3. Format data into compact text for 32x8 pixel display
4. Build JSON payload conforming to AWTRIX 3 API specification
5. Push to AWTRIX clock via HTTP POST (either persistent custom app or one-shot notification)

**Configuration**: All settings are environment variables with sensible defaults at the top of the script:
- `AWTRIX_IP`: Target clock IP address (default: 192.168.1.30)
- `APP_NAME`: Custom app identifier for AWTRIX (default: berlin_weather)
- `ICON_ID`: Optional weather icon ID (default: 2497)
- `LAT`/`LON`: Berlin coordinates (52.52, 13.41)
- `PUSH_MODE`: Either "custom" (persistent in app loop) or "notify" (one-shot)
- Text uses rainbow mode (animated color cycling)

## Installation

**Automated installation**:
```bash
./install.sh
```

This will:
- Copy scripts to `/Users/liangshi/Utilities/my-ulanzi-clock/`
- Install three launchd plists to `~/Library/LaunchAgents/`
- Schedule tasks:
  - Weather update: Daily at 8:00 AM
  - Clock wake: Daily at 7:58 AM
  - Clock sleep: Daily at 10:00 PM

## Running Scripts Manually

**Weather update**:
```bash
./berlin-weather.sh
```

**Clock sleep/wake control**:
```bash
./clock-sleep-wake.sh wake   # Turn on the display
./clock-sleep-wake.sh sleep  # Turn off the display
```

**Apply clock settings**:
```bash
./clock-settings.sh
```

**With custom settings**:
```bash
# Different location
AWTRIX_IP=192.168.1.50 LAT=48.1351 LON=11.5820 ./berlin-weather.sh

# Control different clock
AWTRIX_IP=192.168.1.50 ./clock-sleep-wake.sh wake
```

## Managing Launch Agents

```bash
# Check status of all agents
launchctl list | grep ulanzi

# Test run immediately
launchctl start de.octostack.ulanzi.berlin-weather
launchctl start de.octostack.ulanzi.wake
launchctl start de.octostack.ulanzi.sleep

# Unload (disable) all agents
launchctl unload ~/Library/LaunchAgents/de.octostack.ulanzi.berlin-weather.plist
launchctl unload ~/Library/LaunchAgents/de.octostack.ulanzi.wake.plist
launchctl unload ~/Library/LaunchAgents/de.octostack.ulanzi.sleep.plist

# Reload after changes
launchctl unload ~/Library/LaunchAgents/de.octostack.ulanzi.*.plist
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.berlin-weather.plist
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.wake.plist
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.sleep.plist
```

**Log files** in `/Users/liangshi/Utilities/my-ulanzi-clock/`:
- `berlin-weather.log` / `berlin-weather.error.log`
- `clock-wake.log` / `clock-wake.error.log`
- `clock-sleep.log` / `clock-sleep.error.log`

## Key Technical Details

**Weather Script (berlin-weather.sh)**:
- Weather codes follow WMO standard (0-99); mapping in berlin-weather.sh:34-48
- Text displays daily temperature range (min-max) in format "1-10°C" (line 56)
- Text uses rainbow mode for animated color cycling
- Error handling: `set -euo pipefail` ensures script fails fast on errors
- API timeout: 10 seconds for Open-Meteo requests (line 26)
- AWTRIX API endpoints: `/api/custom?name=<APP_NAME>` (persistent) or `/api/notify` (temporary)

**Sleep/Wake Script (clock-sleep-wake.sh)**:
- Uses AWTRIX `/api/power` endpoint with `{"power":true}` (wake) or `{"power":false}` (sleep)
- Accepts single argument: `wake` or `sleep`

**Settings Script (clock-settings.sh)**:
- Uses AWTRIX `/api/settings` endpoint to configure clock behavior
- Sets 40+ parameters including brightness, colors, time/date formats, display modes
- All settings documented with inline comments (lines 11-49)
- Key settings: BRI=10 (brightness), TFORMAT="%H %M" (24-hour), DFORMAT="%d.%m.%y" (European date)
- Color values are decimal RGB (16777215=white, 16711680=red, 6710886=gray)

**Launchd Schedules**:
- Weather update: 8:00 AM daily (de.octostack.ulanzi.berlin-weather.plist)
- Clock wake: 7:58 AM daily (de.octostack.ulanzi.wake.plist)
- Clock sleep: 10:00 PM daily (de.octostack.ulanzi.sleep.plist)
