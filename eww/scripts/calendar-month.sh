#!/bin/bash

month_name() {
    case "$1" in
        01) echo "Enero" ;;
        02) echo "Febrero" ;;
        03) echo "Marzo" ;;
        04) echo "Abril" ;;
        05) echo "Mayo" ;;
        06) echo "Junio" ;;
        07) echo "Julio" ;;
        08) echo "Agosto" ;;
        09) echo "Septiembre" ;;
        10) echo "Octubre" ;;
        11) echo "Noviembre" ;;
        12) echo "Diciembre" ;;
    esac
}

year=$(date +%Y)
month=$(date +%m)
today=$(date +%d)
today=$((10#$today))

first_day="${year}-${month}-01"
first_weekday=$(date -d "$first_day" +%u)
days_in_month=$(date -d "$first_day +1 month -1 day" +%d)
days_in_month=$((10#$days_in_month))
title="$(month_name "$month") ${year}"

printf '(box :class "cal-box" :orientation "v" :space-evenly false :spacing 10'
printf ' (box :orientation "h" :space-evenly false :spacing 8'
printf ' (label :class "cal-header-icon" :text "󰃭")'
printf ' (label :class "cal-header-title" :text "%s" :hexpand true :halign "start"))' "$title"
printf ' (box :class "cal-separator" :hexpand true)'
printf ' (box :class "cal-weekdays" :orientation "h" :space-evenly true'

for day in Lun Mar Mié Jue Vie Sáb Dom; do
    printf ' (label :class "cal-weekday" :text "%s")' "$day"
done

printf ')'
printf ' (box :class "cal-grid" :orientation "v" :space-evenly false :spacing 5'

day=1
for week in 1 2 3 4 5 6; do
    printf ' (box :orientation "h" :space-evenly true :spacing 5'

    for dow in 1 2 3 4 5 6 7; do
        if [ "$week" -eq 1 ] && [ "$dow" -lt "$first_weekday" ]; then
            printf ' (label :class "cal-day cal-day-empty" :text "")'
        elif [ "$day" -le "$days_in_month" ]; then
            if [ "$day" -eq "$today" ]; then
                printf ' (label :class "cal-day cal-today" :text "%s")' "$day"
            else
                printf ' (label :class "cal-day" :text "%s")' "$day"
            fi
            day=$((day + 1))
        else
            printf ' (label :class "cal-day cal-day-empty" :text "")'
        fi
    done

    printf ')'
done

printf '))\n'
