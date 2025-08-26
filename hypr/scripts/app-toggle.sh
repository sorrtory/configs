#!/usr/bin/env bash
# Usage: app-toggle.sh <window_class> <workspace> [<launch_command>]
#
# To get <window_class>, run:
#     hyprctl -j clients | jq '.[] | {class, title}'
# while the app is running, and copy the "class" exactly (case-sensitive).
#
# Example:
#     app-toggle.sh zen 1 zen-browser
#     app-toggle.sh Code 2 code

CLASS="$1"
WS="$2"
LAUNCH_CMD="${3:-$1}"

LOCKFILE="/tmp/app-toggle-$CLASS.lock"
LOCK_DELAY=2     # seconds before another launch can happen
POLL_TIMEOUT=5   # seconds to wait for new window
POLL_INTERVAL=0.1

if [ -z "$CLASS" ] || [ -z "$WS" ]; then
    echo "Usage: $0 <window_class> <workspace> [launch_command]"
    exit 1
fi

# Find first matching window by class
find_window_by_class() {
    hyprctl -j clients | jq -r --arg class "$CLASS" '
        .[] | select(.class == $class) | .address' | head -n 1
}

ADDR=$(find_window_by_class)

if [ -n "$ADDR" ]; then
    # Existing instance: move it to correct workspace and focus
    hyprctl dispatch movetoworkspace "${WS},address:${ADDR}"
    hyprctl dispatch workspace "$WS"
    hyprctl dispatch focuswindow "address:${ADDR}"
    exit 0
fi

# Prevent multiple fast launches
if [ -f "$LOCKFILE" ]; then
    LAST_TIME=$(cat "$LOCKFILE")
    NOW=$(date +%s)
    if (( NOW - LAST_TIME < LOCK_DELAY )); then
        exit 0
    fi
fi
date +%s > "$LOCKFILE"

# Launch directly into target workspace
hyprctl dispatch exec "[workspace $WS] $LAUNCH_CMD"

# Poll until the app window appears or timeout
SECONDS_WAITED=0
while [ "$SECONDS_WAITED" -lt "$POLL_TIMEOUT" ]; do
    ADDR=$(find_window_by_class)
    if [ -n "$ADDR" ]; then
        hyprctl dispatch focuswindow "address:${ADDR}"
        exit 0
    fi
    sleep "$POLL_INTERVAL"
    SECONDS_WAITED=$(echo "$SECONDS_WAITED + $POLL_INTERVAL" | bc)
done

