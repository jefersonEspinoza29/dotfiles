#!/bin/bash
/usr/bin/brillo -G | /usr/bin/awk '{printf "%d\n", $1}'
