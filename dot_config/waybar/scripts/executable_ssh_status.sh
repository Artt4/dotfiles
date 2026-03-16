#!/bin/bash
COUNT=$(who | grep -c "pts/")

if [ "$COUNT" -gt 0 ]; then
    # text: The icon that stays in the bar
    # tooltip: The detailed info shown on hover
    echo "{\"text\": \"\", \"tooltip\": \"SSH sessions: $COUNT\", \"class\": \"connected\"}"
else
    echo "{\"text\": \"\", \"class\": \"disconnected\"}"
fi
