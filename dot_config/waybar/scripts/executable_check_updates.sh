#!/bin/bash

CACHE_FILE="/tmp/waybar-updates.cache"
# 10 minute cache
CACHE_AGE=600

function get_updates_silently() {
    # Fetch updates (the slow part)
    official_list=$(checkupdates 2>/dev/null)
    aur_list=$(yay -Qua 2>/dev/null)

    official_count=$(echo "$official_list" | grep -cv '^$')
    aur_count=$(echo "$aur_list" | grep -cv '^$')
    total=$((official_count + aur_count))

    icon="󰚰"
    note="Updates"
    class="standard"

    # Critical Check
    if echo "$official_list $aur_list" | grep -iqE -w "hyprland|linux-cachyos|nvidia|amd-ucode|mesa|wayland|systemd|limine"; then
        note="MAJOR UPDATE DETECTED"
        class="critical"
    fi

    # Write to cache
    if [ "$total" -gt 0 ]; then
        echo "{\"text\": \"$icon $total\", \"tooltip\": \"$note\\nOfficial: $official_count\\nAUR: $aur_count\", \"class\": \"$class\"}" > "$CACHE_FILE"
    else
        echo "{\"text\": \"󰚰\", \"tooltip\": \"System fully updated\", \"class\": \"uptodate\"}" > "$CACHE_FILE"
    fi

    # Tell Waybar to refresh now that we have the data
    pkill -SIGRTMIN+8 waybar
}

# 1. If an update check is ALREADY running, don't start another one
if pgrep -x "checkupdates" > /dev/null; then
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
    else
        echo '{"text": "...", "tooltip": "Checking for updates...", "class": "loading"}'
    fi
    exit 0
fi

# 2. If no cache exists, show loading and start background check
if [[ ! -f "$CACHE_FILE" ]]; then
    echo '{"text": "...", "tooltip": "Checking for updates...", "class": "loading"}'
    get_updates_silently &
    exit 0
fi

# 3. If cache is old, show old data but trigger background refresh
if [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -gt $CACHE_AGE ]]; then
    cat "$CACHE_FILE"
    get_updates_silently &
    exit 0
fi

# 4. Otherwise, just show the fresh cache
cat "$CACHE_FILE"
