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
    log_info "$action" "Config loaded from $conf_file"
}


run_pre_checks() {
    # validate_root
    validate_src_dir "$SOURCE_DIR" || exit 1
    validate_dst_dir "$DEST_DIR" || exit 1
    validate_dst_free "$DEST_DIR" "$DST_FREE_THR" || exit 1
    log_info "PRE-CHECKS" "All validations passed"    
}


backup_full() {
    local action="BACKUP_FULL"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$DEST_DIR/backup_full_${timestamp}.tar.gz"
    log_info "$action" "Starting full backup of $SOURCE_DIR to $backup_file"
    tar czf "$backup_file" -C "$SOURCE_DIR" . 2>/dev/null
    if [[ $? -eq 0 ]]; then
        log_info "$action" "Full backup successful"
        echo "$backup_file" > "$DEST_DIR/last_full_backup.txt"
    else
        log_error "$action" "Full backup failed"
        return 1
    fi
}


backup_incremental() {
    local action="BACKUP_INC"
    local last_full
    if [[ -f "$DEST_DIR/last_full_backup.txt" ]]; then
        last_full=$(cat "$DEST_DIR/last_full_backup.txt")
    else
        log_error "$action" "No previous full backup found. Run full backup first."
        return 1
    fi

    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local inc_file="$DEST_DIR/backup_inc_${timestamp}.tar.gz"

    log_info "$action" "Starting incremental backup based on $last_full"
    tar czf "$inc_file" -C "$SOURCE_DIR" --newer="$last_full" . 2>/dev/null
    if [[ $? -eq 0 ]]; then
        log_info "$action" "Incremental backup successful: $inc_file"
        echo "$inc_file" >> "$DEST_DIR/incremental_backups.log"
    else
        log_warning "$action" "No changes detected or incremental backup failed"
    fi
}


verify_backup() {
    local action="BACKUP_VERIFY"
    local backup_file="$1"
    if tar tzf "$backup_file" >/dev/null 2>&1; then
        log_info "$action" "Backup $backup_file is valid"
        return 0
    else
        log_error "$action" "Backup $backup_file is corrupt"
        return 1
    fi
}


cleanup_old_backups() {
    local action="BACKUP_CLEANUP"
    local days_to_keep="${RETENTION_DAYS:-7}"
    log_info "$action" "Removing backups older than $days_to_keep days from $DEST_DIR"
    find "$DEST_DIR" -name "backup_*.tar.gz" -type f -mtime +"$days_to_keep" -delete
}


main() {
    local action="MAIN"
    read_config "$CONFIG_FILE"
    run_pre_checks

    local last_full
    last_full=$(find "$DEST_DIR" -name "backup_full_*.tar.gz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

    local days_since_full=999
    if [[ -n "$last_full" && -f "$last_full" ]]; then
        local last_full_ts
        last_full_ts=$(stat -c %Y "$last_full")
        local now_ts
        now_ts=$(date +%s)
        days_since_full=$(( (now_ts - last_full_ts) / 86400 ))
    fi

    if [[ -z "$last_full" || $days_since_full -ge $RETENTION_DAYS ]]; then
        log_info "$action" "No recent full backup found (last: $days_since_full days ago). Running full backup."
        backup_full
        verify_backup "$(cat "$DEST_DIR/last_full_backup.txt")" || exit 1
    else
        log_info "$action" "Recent full backup found (age: $days_since_full days). Running incremental backup."
        backup_incremental

        local last_inc
        last_inc=$(find "$DEST_DIR" -name "backup_inc_*.tar.gz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
        if [[ -n "$last_inc" && -f "$last_inc" ]]; then
            verify_backup "$last_inc"
        fi
    fi

    cleanup_old_backups
    log_info "$action" "Backup process completed successfully"
}

main
