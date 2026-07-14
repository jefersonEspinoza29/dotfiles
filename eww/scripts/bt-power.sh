#!/bin/bash
bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && echo "on" || echo "off"
