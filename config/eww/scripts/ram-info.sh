#!/bin/bash
free -h | awk '/Mem:/ {printf "%s/%s\n", $3, $2}'
