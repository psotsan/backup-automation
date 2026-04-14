#!/bin/bash

. ./lib/logging.sh

set -euo pipefail


process_args() {
    echo "$#"
    if [[ $# -gt 0 && $(($# % 2)) -eq 0 ]]; then
        while [[ "$#" > 0 ]]; do
            case "$1" in
                -c) shift
                    CONFIG_FILE="$1"
                    shift
                    ;;
                # Use ERROR when logging module is implemente
                *) echo "[-] Unknown option $1" >&2
                   exit 1
                   ;;
            esac
        done
    else
        # Use ERROR when logging module is omplemented
        echo "[-] Usage: $0 -c <config_file>" >&2
        exit 1
    fi
}


read_config() {
    while IFS='=' read -r key val; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue

        key=$(echo "$key" | xargs)
        val=$(echo "$val" | xargs)

        case "$key" in
            USER) USER="$val";;
            SECRET) SECRET="$val";;
            SOURCE_DIR) SOURCE_DIR="$val";;
            DEST_DIR) DEST_DIR="$val";;
            # Use WARNING when logging  module is implemented
            *) echo "[-] Unknown variable $key ignored" >&2;;
        esac
    done < "$CONFIG_FILE"
}


log_debug "START" "Testing logging module"

process_args $@
echo "[+] CONFIG_FILE = $CONFIG_FILE"

if [[ -z "$CONFIG_FILE" ]]; then
    CONFIG_FILE="config/config.conf"
fi

echo "[+] CONFIG_FILE = $CONFIG_FILE"

read_config "$CONFIG_FILE"
