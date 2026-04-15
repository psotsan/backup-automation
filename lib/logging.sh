#!/bin/bash

log_wrapper() {
    local level="$1"
    local action="$2"
    local detail="$3"
    local timestamp
    timestamp="$(date +%Y-%m-%d-%H:%M%S%z)"
    local fallback="./backup_fallback.log"

    if [[ -z "$action" ]]; then
        action="ACTION_NOT_DEFINED"
        echo "[VALIDATION] Missing 'action' parameter in log call" >&2
    fi

    if [[ -z "$detail" ]]; then
        detail="DETAILS_NOT_DEFINED"
        echo "[VALIDATION] Missing 'detail' parameter im log call" >&2
    fi

    local msg="[$timestamp] [${level^^}] [$action] [$detail]" 
   
    if command -v logger >/dev/null 2>&1; then
        logger -t "$0" -p "local0.$level" "$msg"
    else
        echo "$msg" >> "$fallback"
        echo "WARNING: syslog unavailable, writing to $fallback" >&2
    fi

    return 0
}


log_info() {
    local action="$1"
    local detail="$2"

    log_wrapper "info" "$action" "$detail"
}


log_warning() {
    local action="$1"
    local detail="$2"

    log_wrapper "warning" "$action" "$detail"
}


log_error() {
    local action="$1"
    local detail="$2"

    log_wrapper "error" "$action" "$detail"
}


log_debug() {
    local action="$1"
    local detail="$2"

    log_wrapper "debug" "$action" "$detail"
}


log_crit() {
    local action="$1"
    local detail="$2"

    log_wrapper "crit" "$action" "$detail"
}


[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exit 1

