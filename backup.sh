#!/bin/bash

. ./lib/logging.sh
. ./lib/validation.sh

set -euo pipefail

CONFIG_FILE="config/config.conf"


read_config() {
    local conf_file="$1"
    local action="CONFIG"
    
    if [[ ! -f "$conf_file" || ! -r "$conf_file" ]]; then
       log_error "$action" "Config file not found or not readable: $conf_file"
       exit 1
    fi
    
    . "$conf_file"
    log_info "$action" "Config loaded form $conf_file"
}


run_pre_checks() {
    # validate_root
    validate_src_dir "$SOURCE_DIR" || exit 1
    validate_dst_dir "$DEST_DIR" || exit 1
    validate_dst_free "$DEST_DIR" "$DST_FREE_THR" || exit 1
    log_info "PRE-CHECKS" "All validations passed"    
}


main() {
    read_config "$CONFIG_FILE"
    run_pre_checks
}


main
