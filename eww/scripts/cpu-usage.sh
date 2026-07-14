#!/bin/bash
read -r -a prev < <(grep '^cpu ' /proc/stat)
sleep 0.8
read -r -a curr < <(grep '^cpu ' /proc/stat)

prev_idle=$(( prev[4] + prev[5] ))
curr_idle=$(( curr[4] + curr[5] ))

prev_total=0
for v in "${prev[@]:1}"; do prev_total=$(( prev_total + v )); done
curr_total=0
for v in "${curr[@]:1}"; do curr_total=$(( curr_total + v )); done

diff_idle=$(( curr_idle - prev_idle ))
diff_total=$(( curr_total - prev_total ))

[ "$diff_total" -eq 0 ] && echo 0 && exit
echo $(( (diff_total - diff_idle) * 100 / diff_total ))
