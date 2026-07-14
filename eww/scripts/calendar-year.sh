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

render_month() {
    local month="$1"
    local month_num title first_day first_weekday days_in_month day week dow

    month_num=$((10#$month))
    title=$(month_name "$month")
    first_day="${year}-${month}-01"
    first_weekday=$(date -d "$first_day" +%u)
    days_in_month=$(date -d "$first_day +1 month -1 day" +%d)
    days_in_month=$((10#$days_in_month))

    printf ' (box :class "cal-year-month" :orientation "v" :space-evenly false :spacing 5'
    printf ' (label :class "cal-year-month-title" :text "%s")' "$title"
    printf ' (box :orientation "h" :space-evenly true'

    for day_name in L M X J V S D; do
        printf ' (label :class "cal-year-weekday" :text "%s")' "$day_name"
    done

    printf ')'
    printf ' (box :orientation "v" :space-evenly false :spacing 2'

    day=1
    for week in 1 2 3 4 5 6; do
        printf ' (box :orientation "h" :space-evenly true :spacing 2'

        for dow in 1 2 3 4 5 6 7; do
            if [ "$week" -eq 1 ] && [ "$dow" -lt "$first_weekday" ]; then
                printf ' (label :class "cal-year-day cal-day-empty" :text "")'
            elif [ "$day" -le "$days_in_month" ]; then
                if [ "$month_num" -eq "$current_month" ] && [ "$day" -eq "$today" ]; then
                    printf ' (label :class "cal-year-day cal-today" :text "%s")' "$day"
                else
                    printf ' (label :class "cal-year-day" :text "%s")' "$day"
                fi
                day=$((day + 1))
            else
                printf ' (label :class "cal-year-day cal-day-empty" :text "")'
            fi
        done

        printf ')'
    done

    printf '))'
}

year=$(date +%Y)
current_month=$(date +%m)
current_month=$((10#$current_month))
today=$(date +%d)
today=$((10#$today))

printf '(box :class "cal-box cal-year-box" :orientation "v" :space-evenly false :spacing 10'
printf ' (box :orientation "h" :space-evenly false :spacing 8'
printf ' (label :class "cal-header-icon" :text "󰃭")'
printf ' (label :class "cal-header-title" :text "%s" :hexpand true :halign "start"))' "$year"
printf ' (box :class "cal-separator" :hexpand true)'
printf ' (box :orientation "h" :space-evenly true :spacing 8'

for month in 01 02 03 04; do
    render_month "$month"
done

printf ') (box :orientation "h" :space-evenly true :spacing 8'

for month in 05 06 07 08; do
    render_month "$month"
done

printf ') (box :orientation "h" :space-evenly true :spacing 8'

for month in 09 10 11 12; do
    render_month "$month"
done

printf '))\n'
