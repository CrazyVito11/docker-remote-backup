#!/bin/bash

set -e

TIMESTAMP=$(date +"%Y-%m-%d-%H%M")

LOG_DIR="/logs"
LOG_FILE="${LOG_DIR}/${TIMESTAMP}-rclone.log"

LOCK_FILE="/var/lock/sync-now.lock"
SUCCESS_SCRIPT="/hooks/backup-success.sh"
FAILURE_SCRIPT="/hooks/backup-failure.sh"
LOCK_PRESENT_SCRIPT="/hooks/lock-present.sh"


run_script_if_exists() {
    local script_path="$1"

    if [[ -f "$script_path" ]]; then
        echo "Executing script: $script_path"

        if ! bash "$script_path"; then
            echo "Warning: Execution of $script_path failed"
        fi
    fi
}

# Function to clean up lock file on exit
cleanup() {
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
    fi
}



# Ensure no other instance is running
if [[ -f "$LOCK_FILE" ]]; then
    echo "Another instance of sync-now.sh is running. Exiting."
    run_script_if_exists "$LOCK_PRESENT_SCRIPT"
    exit 1
fi


# Run cleanup on exit
trap cleanup EXIT


touch "$LOCK_FILE"



# Update the rclone configuration
bash /config/rclone-template/generate-rclone-conf.sh /config/rclone-template/rclone.conf > /config/rclone/rclone.conf

# Start syncing
echo "Starting backup..."
if rclone sync "/data${SOURCE_DIRECTORY}" "remote_backup:/" -v --metadata --create-empty-src-dirs --copy-links --stats 60s --log-file="$LOG_FILE"; then
    echo "Backup successful."
    run_script_if_exists "$SUCCESS_SCRIPT"
else
    echo "Backup failed. Check the log file at $LOG_FILE for details."
    run_script_if_exists "$FAILURE_SCRIPT"
    exit 1
fi
