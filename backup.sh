#!/bin/bash

. ./lib/logging.sh
. ./lib/validation.sh

set -euo pipefail


process_args() {
    local action="PROCESSING_ARGS"
    echo "$#"
    if [[ $# -gt 0 && $(($# % 2)) -eq 0 ]]; then
        while [[ "$#" -gt 0 ]]; do
            case "$1" in
                -c) shift
                    CONFIG_FILE="$1"
                    shift
                    ;;
                *) echo "[-] Unknown option $1" >&2
                    log_error "$action" "Unknow option $1"
                   exit 1
                   ;;
            esac
        done
    else
        echo "[-] Usage: $0 -c <config_file>" >&2
        log_error "$action" "Script misuse"
        exit 1
    fi
}


read_config() {
    local action="READ_CONFIG"
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
            DST_FREE_THR) DST_FREE_THR="$val";;
            # Use WARNING when logging  module is implemented
            *) echo "[-] Unknown variable $key ignored" >&2
            log_warning "$action" "Unkown variable defined in CONFIG_FILE"
            ;;
        esac
    done < "$CONFIG_FILE"
}


run_pre_checks() {
    
}

log_debug "START" "Testing logging module"

process_args "$@"
echo "[+] CONFIG_FILE = $CONFIG_FILE"

if [[ -z "$CONFIG_FILE" ]]; then
    CONFIG_FILE="config/config.conf"
fi

echo "[+] CONFIG_FILE = $CONFIG_FILE"

read_config "$CONFIG_FILE"
