# My Ulanzi Clock

Automated weather display and power management for AWTRIX 3 LED pixel clocks.

![Berlin Weather Display](images/berlin-weather.png)

## Features

- **Weather Display**: Fetches current weather data for Berlin and displays temperature range with rainbow text animation
- **Auto Power Management**: Automatically wakes the clock in the morning and puts it to sleep at night
- **Scheduled Updates**: Uses macOS launchd to run tasks automatically

## Quick Start

### Prerequisites

- macOS with launchd
- AWTRIX 3 LED pixel clock on your network
- Standard Unix utilities: `bash`, `curl`, `jq`

### Installation

1. Clone this repository
2. Run the installation script:

```bash
./install.sh
```

This will:
- Copy scripts to `/Users/liangshi/Utilities/my-ulanzi-clock/`
- Install launchd agents for automatic scheduling
- Set up the following schedule:
  - **7:58 AM**: Clock wake
  - **8:00 AM**: Weather update
  - **10:00 PM**: Clock sleep

### Configuration

Edit the environment variables at the top of `berlin-weather.sh`:

```bash
AWTRIX_IP="192.168.1.30"      # Your clock's IP address
APP_NAME="berlin_weather"     # Custom app name
ICON_ID="2497"                # Weather icon ID
LAT="52.52"                   # Latitude (Berlin)
LON="13.41"                   # Longitude (Berlin)
PUSH_MODE="custom"            # "custom" or "notify"
```

## Usage

### Manual Execution

**Update weather display:**
```bash
./berlin-weather.sh
```

**Control clock power:**
```bash
./clock-sleep-wake.sh wake    # Turn on
./clock-sleep-wake.sh sleep   # Turn off
```

**Use custom settings:**
```bash
# Different location
AWTRIX_IP=192.168.1.50 LAT=48.1351 LON=11.5820 ./berlin-weather.sh

# Different clock
AWTRIX_IP=192.168.1.50 ./clock-sleep-wake.sh wake
```

### Managing Launch Agents

**Check status:**
```bash
launchctl list | grep ulanzi
```

**Test immediately:**
```bash
launchctl start de.octostack.ulanzi.berlin-weather
launchctl start de.octostack.ulanzi.wake
launchctl start de.octostack.ulanzi.sleep
```

**Reload after changes:**
```bash
launchctl unload ~/Library/LaunchAgents/de.octostack.ulanzi.*.plist
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.berlin-weather.plist
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.wake.plist
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.sleep.plist
```

**Disable (unload) agents:**
```bash
launchctl unload ~/Library/LaunchAgents/de.octostack.ulanzi.berlin-weather.plist
launchctl unload ~/Library/LaunchAgents/de.octostack.ulanzi.wake.plist
launchctl unload ~/Library/LaunchAgents/de.octostack.ulanzi.sleep.plist
```

### Logs

Log files are created at `/Users/liangshi/Utilities/my-ulanzi-clock/`:
- `berlin-weather.log` / `berlin-weather.error.log`
- `clock-wake.log` / `clock-wake.error.log`
- `clock-sleep.log` / `clock-sleep.error.log`

## How It Works

### Weather Script

1. Fetches weather data from [Open-Meteo API](https://open-meteo.com/) (free, no API key required)
2. Extracts daily min/max temperature
3. Maps WMO weather codes to German condition labels
4. Formats as compact text (e.g., "1-10°C")
5. Sends to AWTRIX clock via HTTP POST with rainbow text animation

### Sleep/Wake Script

Uses the AWTRIX `/api/power` endpoint to control display power state.

## Technical Details

- **Weather codes**: WMO standard (0-99) mapped to German labels
- **Display format**: Temperature range in °C with rainbow animation
- **Error handling**: Scripts use `set -euo pipefail` for fail-fast behavior
- **API timeout**: 10 seconds for weather requests
- **AWTRIX endpoints**:
  - `/api/custom?name=<APP_NAME>` (persistent)
  - `/api/notify` (one-shot)
  - `/api/power` (sleep/wake)

For complete API documentation, see the [AWTRIX 3 API Documentation](https://blueforcer.github.io/awtrix3/#/api).

## License

This project is provided as-is for personal use.
