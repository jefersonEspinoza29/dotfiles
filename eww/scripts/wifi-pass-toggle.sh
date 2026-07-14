#!/bin/bash
current=$(eww get wifi-pass-show)
if [ "$current" = "true" ]; then
    eww update wifi-pass-show=false
else
    eww update wifi-pass-show=true
fi
