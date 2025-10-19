#!/usr/bin/env bash
set -euo pipefail

# ========= User config =========
AWTRIX_IP="${AWTRIX_IP:-192.168.1.30}"     # <- change to your clock's IP

# ========= Parse command =========
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <wake|sleep>"
    echo "  wake  - Turn on the clock display"
    echo "  sleep - Turn off the clock display"
    exit 1
fi

ACTION="$1"

# ========= Send command to AWTRIX =========
case "$ACTION" in
    wake)
        echo "Waking up clock at ${AWTRIX_IP}..."
        curl -fsS -X POST "http://${AWTRIX_IP}/api/power" \
             -H "Content-Type: application/json" \
             -d '{"power":true}' >/dev/null
        echo "Clock is now awake"
        ;;
    sleep)
        echo "Putting clock to sleep at ${AWTRIX_IP}..."
        curl -fsS -X POST "http://${AWTRIX_IP}/api/power" \
             -H "Content-Type: application/json" \
             -d '{"power":false}' >/dev/null
        echo "Clock is now asleep"
        ;;
    *)
        echo "Error: Unknown action '$ACTION'"
        echo "Usage: $0 <wake|sleep>"
        exit 1
        ;;
esac
