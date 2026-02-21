#!/usr/bin/env bash

# --- Configuration ---
# IMPORTANT: Replace "Wacom PTH-451" with the actual name of your tablet
# as it appears in OTD or when running `otd listdevices`.
TABLET_NAME="Wacom PTH-451"

# Define the full mode names for setting the output
ABSOLUTE_MODE="OpenTabletDriver.Desktop.Output.AbsoluteMode"
ARTIST_MODE="OpenTabletDriver.Desktop.Output.LinuxArtistMode"

# --- Script Logic ---

# 1. Get the current output mode
# We pipe the output of 'otd getoutputmode' to awk to extract just the mode name.
CURRENT_MODE=$(otd getoutputmode "$TABLET_NAME" | awk -F"'" '{print $2}')

# 2. Check the current mode and set the new mode
NEW_MODE=""
NOTIFICATION_TEXT=""

if [ "$CURRENT_MODE" == "Absolute Mode" ]; then
    # Currently in Absolute Mode, switch to Artist Mode
    NEW_MODE="$ARTIST_MODE"
    NOTIFICATION_TEXT="Tablet Switched: Linux Artist Mode (Specialized)"
elif [ "$CURRENT_MODE" == "Artist Mode" ]; then
    # Currently in Artist Mode, switch to Absolute Mode
    NEW_MODE="$ABSOLUTE_MODE"
    NOTIFICATION_TEXT="Tablet Switched: Absolute Mode (Mouse Emulation)"
else
    # Currently in an unknown/different mode (e.g., Relative), default to Artist Mode
    echo "Warning: Tablet is in unknown mode ('$CURRENT_MODE'). Defaulting to Artist Mode."
    NEW_MODE="$ARTIST_MODE"
    NOTIFICATION_TEXT="Tablet Switched: Linux Artist Mode (Default)"
fi

# 3. Execute the mode change command
if [ -n "$NEW_MODE" ]; then
    otd setoutputmode "$TABLET_NAME" "$NEW_MODE"

    # 4. Optional: Send a desktop notification (requires dunst or similar)
    if command -v notify-send &> /dev/null; then
      notify-send \
        -r 8132165 \
        -u low \
        -t 3000 \
        -h boolean:transient:true \
        "OpenTabletDriver" "$NOTIFICATION_TEXT"
    fi
fi
