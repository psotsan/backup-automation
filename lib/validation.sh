#!/bin/bash

# shellcheck source=logging.sh
. ./lib/logging.sh


validate_root() {
    local action="VALIDATE_ROOT_USER"
    if [[ $UID -ne 0 ]]; then
        log_error "$action" "User IS NOT root"
        return 1
    fi    
    
    log_info "$action" "User IS root"
}


validate_src_dir() {
    local dir="$1"
    local action="VALIDATE_SOURCE_DIR"
    
    if [[ ! -d "$dir" ]]; then
        log_error "$action" "Source directory $dir DOES NOT exist"
        return 1
    fi

    log_info "$action" "Source directory $dir exists"

    if [[ ! -r "$dir" ]]; then
        log_error "$action" "Source directory $dir IS NOT readable"
        return 1
    fi

    log_info "$action" "Source directory $dir IS readable"
}


validate_dst_dir() {
    local dir="$1"
    local action="VALIDATE_DESTINATION_DIR"
    
    if [[ ! -d "$dir" ]]; then
        log_error "$action" "Destination directory $dir DOES NOT exists"
        return 1
    fi

    log_info "$action" "Destinantion directory $dir exists"

    if [[ ! -w "$dir" ]]; then
        log_error "$action" "Destination directory $dir IS NOT writable"
        return 1
    fi
    
    log_info "$action" "Destination directory $dir IS writable"
}


validate_dst_free() {
    local dir=$1
    local threshold=$2
    local action="VALIDATE_FREE_SPACE_ON_DESTINATION"
    local used
    local free
    used=$(df "$dir" | tail -n 1 | awk '{print $5}' | cut -d % -f 1)
    free=$((100 - used))

    if [[ $free -lt $threshold ]]; then
        log_error "$action" "Not enough free space in $dir"
        return 1
    fi

    log_info "$action" "Enough free space in $dir"
}


[[ "${BASH_SOURCE[0]}" == "$0"  ]] && exit 1
