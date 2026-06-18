#!/bin/bash
nmcli radio wifi 2>/dev/null | grep -q "enabled" && echo "on" || echo "off"
