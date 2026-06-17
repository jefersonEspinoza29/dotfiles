#!/bin/bash
/usr/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | /usr/bin/awk '{printf "%d\n", $2 * 100}'
