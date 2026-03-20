#!/bin/bash

pkill waybar
pkill swaync

sleep 0.2

waybar &
swaync &
