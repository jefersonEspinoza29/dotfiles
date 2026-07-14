#!/bin/bash
last=""

stdbuf -oL cava -p ~/.config/eww/cava.ini \
  | stdbuf -oL sed 's/[^0-9;]//g' \
  | stdbuf -oL grep -v '^$' \
  | while IFS=';' read -r -a vals; do
    h1=${vals[0]:-2};  [ "$h1"  -lt 2 ] && h1=2
    h2=${vals[1]:-2};  [ "$h2"  -lt 2 ] && h2=2
    h3=${vals[2]:-2};  [ "$h3"  -lt 2 ] && h3=2
    h4=${vals[3]:-2};  [ "$h4"  -lt 2 ] && h4=2
    h5=${vals[4]:-2};  [ "$h5"  -lt 2 ] && h5=2
    h6=${vals[5]:-2};  [ "$h6"  -lt 2 ] && h6=2
    h7=${vals[6]:-2};  [ "$h7"  -lt 2 ] && h7=2
    h8=${vals[7]:-2};  [ "$h8"  -lt 2 ] && h8=2
    h9=${vals[8]:-2};  [ "$h9"  -lt 2 ] && h9=2
    h10=${vals[9]:-2}; [ "$h10" -lt 2 ] && h10=2

    current="$h1;$h2;$h3;$h4;$h5;$h6;$h7;$h8;$h9;$h10"
    [ "$current" = "$last" ] && continue

    last="$current"
    eww update bar1=$h1 bar2=$h2 bar3=$h3 bar4=$h4 bar5=$h5 \
               bar6=$h6 bar7=$h7 bar8=$h8 bar9=$h9 bar10=$h10
done
