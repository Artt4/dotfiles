#!/bin/bash
# This version only counts sessions that have an associated IP/Hostname (SSH)
COUNT=$(who | grep "pts/" | grep -c "(.*)")

if [ "$COUNT" -gt 0 ]; then
    echo "{\"text\": \"\", \"tooltip\": \"SSH sessions: $COUNT\", \"class\": \"connected\"}"
else
    echo "{\"text\": \"\", \"class\": \"disconnected\"}"
fi
