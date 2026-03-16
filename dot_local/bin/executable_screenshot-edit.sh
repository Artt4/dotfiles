#!/bin/bash

# 1. Setup
MODE=${1:-region}
FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
TEMP_FILE="/tmp/$FILENAME"

# Validate mode argument
case "$MODE" in
    region|window|output) ;;
    *)
        echo "Invalid mode: '$MODE'. Use region, window, or output." >&2
        exit 1
        ;;
esac

# Ensure temp file is always cleaned up on exit
trap 'rm -f "$TEMP_FILE"' EXIT

# 2. Capture
sleep 0.1
hyprshot -m "$MODE" -o /tmp -f "$FILENAME" --silent

# 3. Wait for file to exist and have content (handles both slow writes and Escape cancellation)
MAX_ATTEMPTS=20
ATTEMPT=0
while [ ! -s "$TEMP_FILE" ] && [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; do
    sleep 0.1
    ((ATTEMPT++))
done

# 4. Handle cancellation — if file still missing or empty after waiting, exit silently
if [ ! -s "$TEMP_FILE" ]; then
    exit 0
fi

# 5. Shutter sound
canberra-gtk-play -i screen-capture &

# 6. Copy to clipboard
wl-copy < "$TEMP_FILE"

# 7. Notification (click to open in editor)
ACTION=$(notify-send \
    -a "Hyprshot" \
    "Captured $MODE" \
    "Saved to clipboard. Click to edit/save." \
    --icon="$TEMP_FILE" \
    --action="default=body_click")

if [[ "$ACTION" == "default" ]]; then
    swappy -f "$TEMP_FILE"
fi
