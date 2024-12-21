#!/bin/bash

set -e

# TODO: Implement lock file in case the backup is still running
# TODO: Implement ability to run a script once the backup is successful
# TODO: Implement ability to run a script if the backup failed
# TODO: Implement ability to run a script if the lock file is still present (possibly indicating a still running backup process)

# Update the rclone configuration
bash /config/rclone-template/generate-rclone-conf.sh /config/rclone-template/rclone.conf > /config/rclone/rclone.conf

# Start syncing
rclone sync "/data${SOURCE_DIRECTORY}" "remote_backup:/" -v --metadata --create-empty-src-dirs --copy-links --stats 60s --log-file="/logs/rclone.log"
