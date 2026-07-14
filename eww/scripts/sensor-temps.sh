#!/bin/bash
# Genera yuck markup con temperaturas desde lm_sensors.

sensors_output=$(sensors 2>/dev/null)

if [ -z "$sensors_output" ]; then
    echo '(label :class "temp-empty" :text "Sensores no disponibles")'
    exit 0
fi

get_temp() {
    local chip="$1"
    local label="$2"

    printf '%s\n' "$sensors_output" | awk -v chip="$chip" -v label="$label" '
        $0 == chip { in_block = 1; next }
        in_block && NF == 0 { exit }
        in_block && index($0, label) == 1 {
            line = $0
            sub(/^[^:]*:[[:space:]]*/, "", line)
            if (match(line, /[+-]?[0-9]+(\.[0-9]+)?/)) {
                value = substr(line, RSTART, RLENGTH)
                printf "%.0f", value
                exit
            }
        }
    '
}

get_gpu_temp() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null |
            awk 'NR == 1 && $1 ~ /^[0-9]+$/ { print $1 }'
    fi
}

temp_text() {
    local value="$1"

    if [ -n "$value" ]; then
        printf '%s°C' "$value"
    else
        printf 'N/D'
    fi
}

row() {
    local icon="$1"
    local name="$2"
    local value="$3"
    local class="$4"

    printf ' (box :class "temp-row %s" :orientation "h" :space-evenly false :spacing 8
      (label :class "temp-icon" :text "%s")
      (label :class "temp-name" :text "%s" :hexpand true :halign "start")
      (label :class "temp-value" :text "%s"))' "$class" "$icon" "$name" "$(temp_text "$value")"
}

wifi=$(get_temp "iwlwifi_1-virtual-0" "temp1:")
ram1=$(get_temp "spd5118-i2c-18-52" "temp1:")
ram2=$(get_temp "spd5118-i2c-18-50" "temp1:")
cpu=$(get_temp "coretemp-isa-0000" "Package id 0:")
gpu=$(get_gpu_temp)
nvme1=$(get_temp "nvme-pci-e200" "Composite:")
nvme2=$(get_temp "nvme-pci-e100" "Composite:")

rows=""
rows+="$(row "󰻠" "CPU" "$cpu" "temp-cpu")"
rows+="$(row "󰾲" "GPU" "$gpu" "temp-gpu")"
rows+="$(row "󰍛" "RAM 1" "$ram1" "temp-ram")"
rows+="$(row "󰍛" "RAM 2" "$ram2" "temp-ram")"
rows+="$(row "󰋊" "NVMe 1" "$nvme1" "temp-nvme")"
rows+="$(row "󰋊" "NVMe 2" "$nvme2" "temp-nvme")"
rows+="$(row "󰤨" "Wi-Fi" "$wifi" "temp-wifi")"

printf '(box :class "temp-list" :orientation "v" :space-evenly false :spacing 5 %s)\n' "$rows"
