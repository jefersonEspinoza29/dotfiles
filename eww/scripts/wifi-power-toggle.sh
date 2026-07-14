#!/bin/bash
if nmcli radio wifi 2>/dev/null | grep -q "enabled"; then
    nmcli radio wifi off
else
    nmcli radio wifi on
fi
