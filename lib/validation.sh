#!/bin/bash

# TODO validate_dst_free function

. ./logging.sh

validate_root() {
    local action="VALIDATE_ROOT_USER"
    if [[ $UID -eq 0 ]]; then
        log_info "$action" "User IS root"
        return 0
    else
        log_error "$action" "User IS NOT root"
        return 1
    fi
}


validate_conf_file() {
    local action="VALIDATE_CONFIG_FILE"
    local conf_file="$1"

    if [[ -r conf_file ]]; then
        log_info "$action" "File $conf_file IS readable"
        . "$conf_file"
    else
        log_error "$action" "File $conf_file IS NOT readable"
        return 1
    fi
}


validate_src_dir() {
    local dir="$1"
    local action="VALIDATE_SOURCE_DIR"
    
    if [[ -d "$dir" ]]; then
        log_info "$action" "Source directory $dir exists"
    else
        log_error "$action" "Source directory $dir DOES NOT exist"
        return 1
    fi

    if [[ -r "$dir" ]]; then
        log_info "$action" "Source directory $dir IS readable"
        return 0
    else
        log_error "$action" "Source directory $dir IS NOT readable"
        return 1
    fi
}


validate_dst_dir() {
    local dir="$1"
    local action="VALIDATE_DESTINATION_DIR"
    
    if [[ -d "$dir" ]]; then
        log_info "$action" "Destination directory $dir exists"
    else
        log_error "$action" "Destinantion directory $dir DOES NOT exist"
        return 1
    fi

    if [[ -w "$dir" ]]; then
        log_info "$action" "Destination directory $dir IS writable"
    else
        log_error "$action" "Destination directory $dir IS NOT writable"
        return 1
    fi


}


[[ "${BASH_SOURCE[0]}" == "$0"  ]] && exit 1
