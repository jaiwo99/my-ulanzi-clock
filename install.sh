#!/usr/bin/env bash
set -euo pipefail

# Installation script for berlin-weather AWTRIX clock updater

INSTALL_DIR="/Users/liangshi/Utilities/my-ulanzi-clock"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing berlin-weather to ${INSTALL_DIR}..."

# Create installation directory if it doesn't exist
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Creating directory: ${INSTALL_DIR}"
    mkdir -p "$INSTALL_DIR"
fi

# Copy the scripts
echo "Copying berlin-weather.sh..."
cp "${SCRIPT_DIR}/berlin-weather.sh" "${INSTALL_DIR}/berlin-weather.sh"
chmod +x "${INSTALL_DIR}/berlin-weather.sh"

echo "Copying clock-sleep-wake.sh..."
cp "${SCRIPT_DIR}/clock-sleep-wake.sh" "${INSTALL_DIR}/clock-sleep-wake.sh"
chmod +x "${INSTALL_DIR}/clock-sleep-wake.sh"

# Copy the plist files to LaunchAgents
echo "Installing launchd plists..."
cp "${SCRIPT_DIR}/de.octostack.ulanzi.berlin-weather.plist" ~/Library/LaunchAgents/de.octostack.ulanzi.berlin-weather.plist
cp "${SCRIPT_DIR}/de.octostack.ulanzi.wake.plist" ~/Library/LaunchAgents/de.octostack.ulanzi.wake.plist
cp "${SCRIPT_DIR}/de.octostack.ulanzi.sleep.plist" ~/Library/LaunchAgents/de.octostack.ulanzi.sleep.plist

# Unload existing agents if loaded
for agent in "de.octostack.ulanzi.berlin-weather" "de.octostack.ulanzi.wake" "de.octostack.ulanzi.sleep"; do
    if launchctl list | grep -q "$agent"; then
        echo "Unloading existing agent: $agent..."
        launchctl unload ~/Library/LaunchAgents/${agent}.plist 2>/dev/null || true
    fi
done

# Load the launchd agents
echo "Loading launchd agents..."
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.berlin-weather.plist
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.wake.plist
launchctl load ~/Library/LaunchAgents/de.octostack.ulanzi.sleep.plist

echo ""
echo "Installation complete!"
echo ""
echo "Files installed to: ${INSTALL_DIR}"
echo "Launchd agents:"
echo "  - ~/Library/LaunchAgents/de.octostack.ulanzi.berlin-weather.plist"
echo "  - ~/Library/LaunchAgents/de.octostack.ulanzi.wake.plist"
echo "  - ~/Library/LaunchAgents/de.octostack.ulanzi.sleep.plist"
echo ""
echo "Scheduled tasks:"
echo "  - Weather update: Daily at 8:00 AM"
echo "  - Clock wake:     Daily at 7:58 AM"
echo "  - Clock sleep:    Daily at 10:00 PM"
echo ""
echo "To test immediately:"
echo "  launchctl start de.octostack.ulanzi.berlin-weather"
echo "  launchctl start de.octostack.ulanzi.wake"
echo "  launchctl start de.octostack.ulanzi.sleep"
echo ""
echo "To check status:"
echo "  launchctl list | grep ulanzi"
echo ""
echo "Log files will be created at:"
echo "  ${INSTALL_DIR}/berlin-weather.log"
echo "  ${INSTALL_DIR}/berlin-weather.error.log"
echo "  ${INSTALL_DIR}/clock-wake.log"
echo "  ${INSTALL_DIR}/clock-wake.error.log"
echo "  ${INSTALL_DIR}/clock-sleep.log"
echo "  ${INSTALL_DIR}/clock-sleep.error.log"
