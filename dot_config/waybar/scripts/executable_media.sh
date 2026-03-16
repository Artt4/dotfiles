#!/usr/bin/env bash
dir="$HOME/.config/rofi/applets/type-2/"
theme='style-2'
player="spotify"

# ── Get states ───────────────────────────────────────────────
status=$(playerctl -p "$player" status 2>/dev/null || echo "Stopped")
song=$(playerctl -p "$player" metadata --format '{{title}}' 2>/dev/null || echo "Not playing")
artist=$(playerctl -p "$player" metadata --format '{{artist}}' 2>/dev/null || echo "")
shuffle_status=$(playerctl -p "$player" shuffle 2>/dev/null || echo "Off")

# ── Icons ────────────────────────────────────────────────────
icon_play="󰐊"
icon_pause="󰏤"
icon_next="󰒭"
icon_prev="󰒮"
icon_shuf="󰒝" # We can just use one icon now since the color will change
icon_focus="󰓇"

# ── HIGHLIGHT LOGIC ──────────────────────────────────────────
# Rofi indices start at 0. 
# play=0, next=1, prev=2, shuffle=3, focus=4
active_index=""
if [[ $shuffle_status =~ ^(On|true)$ ]]; then
    active_index="-a 3" # This highlights the 4th button (Shuffle)
fi

# Play/pause icon logic
[[ $status == "Playing" ]] && current_play_icon="$icon_pause" || current_play_icon="$icon_play"

# ── Prompt ───────────────────────────────────────────────────
prompt="${song} — ${artist}"
[[ -z "$artist" ]] && prompt="Spotify"

# ── Build menu ───────────────────────────────────────────────
options="$current_play_icon\n$icon_prev\n$icon_next\n$icon_shuf\n$icon_focus"

ACTION=$(echo -e "$options" \
    | rofi -dmenu \
        $active_index \
        -p "$prompt" \
        -theme "${dir}/${theme}.rasi")

# ── Actions ──────────────────────────────────────────────────
case "$ACTION" in
    "$icon_play"|"$icon_pause")
        playerctl -p "$player" play-pause
        ;;
    "$icon_next")
        playerctl -p "$player" next
        ;;
    "$icon_prev")
        playerctl -p "$player" previous
        ;;
    "$icon_shuf")
        playerctl -p "$player" shuffle toggle
        ;;
    "$icon_focus")
        if hyprctl clients | grep -qi "spotify"; then
            hyprctl dispatch focuswindow "class:^([Ss]potify)$"
        else
            spotify &
        fi
        ;;
esac

