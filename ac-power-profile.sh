#!/bin/bash
# Sets power-profiles-daemon profile based on AC online state.
# Only acts when the AC state actually flipped since last run, so a
# manual profile override (e.g. staying on power-saver while on AC)
# is left alone until the next real plug/unplug transition.
set -euo pipefail

AC_PATH="/sys/class/power_supply/AC/online"
STATE_DIR="/var/lib/ac-power-profile"
STATE_FILE="$STATE_DIR/last-state"

[ -r "$AC_PATH" ] || exit 0
AC_ONLINE="$(cat "$AC_PATH")"

mkdir -p "$STATE_DIR"

LAST_STATE=""
[ -f "$STATE_FILE" ] && LAST_STATE="$(cat "$STATE_FILE")"

if [ "$AC_ONLINE" = "$LAST_STATE" ]; then
    exit 0
fi

echo "$AC_ONLINE" > "$STATE_FILE"

if [ "$AC_ONLINE" = "1" ]; then
    /usr/bin/powerprofilesctl set performance
else
    /usr/bin/powerprofilesctl set power-saver
fi
