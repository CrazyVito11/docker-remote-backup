#!/bin/bash

set -e

# Update the rclone configuration
bash /config/rclone-template/generate-rclone-conf.sh /config/rclone-template/rclone.conf > /config/rclone/rclone.conf

# Start syncing
rclone sync "/data" "remote_backup:$SFTP_HOST_DESTINATION_PATH" -v --metadata --create-empty-src-dirs --stats 60s --log-file="/logs/rclone.log"
