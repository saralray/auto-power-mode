#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DEST="/usr/local/bin/ac-power-profile.sh"
SERVICE_DEST="/etc/systemd/system/ac-power-profile.service"
UDEV_DEST="/etc/udev/rules.d/99-ac-power-profile.rules"
STATE_DIR="/var/lib/ac-power-profile"

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "Elevating privileges with sudo..."
    exec sudo "$0" "$@"
fi

if [ "${1:-}" = "--uninstall" ] || [ "${1:-}" = "uninstall" ]; then
    echo "Uninstalling auto-power-mode..."
    systemctl disable --now ac-power-profile.service 2>/dev/null || true
    rm -f "$UDEV_DEST" "$SERVICE_DEST" "$BIN_DEST"
    rm -rf "$STATE_DIR"
    systemctl daemon-reload
    udevadm control --reload-rules
    echo "Uninstalled successfully."
    exit 0
fi

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    echo "Warning: 'powerprofilesctl' not found. Installing power-profiles-daemon..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y power-profiles-daemon
    else
        echo "Error: Please install 'power-profiles-daemon' manually and re-run." >&2
        exit 1
    fi
fi

echo "Installing script to $BIN_DEST..."
install -m 0755 "$SCRIPT_DIR/ac-power-profile.sh" "$BIN_DEST"

echo "Installing systemd service to $SERVICE_DEST..."
install -m 0644 "$SCRIPT_DIR/ac-power-profile.service" "$SERVICE_DEST"

echo "Installing udev rule to $UDEV_DEST..."
install -m 0644 "$SCRIPT_DIR/99-ac-power-profile.rules" "$UDEV_DEST"

mkdir -p "$STATE_DIR"

echo "Reloading systemd and udev rules..."
systemctl daemon-reload
systemctl enable ac-power-profile.service
udevadm control --reload-rules

echo "Applying initial power profile..."
rm -f "$STATE_DIR/last-state"
systemctl start ac-power-profile.service

echo "Done! Current power profile: $(powerprofilesctl get)"
