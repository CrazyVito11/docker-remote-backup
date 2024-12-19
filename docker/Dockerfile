FROM rclone/rclone:1.68.2

USER root

# Update the local package cache and install dependencies
RUN apk update
RUN apk add fcron bash envsubst

# Prepare the rclone configuration
COPY /rclone /config/rclone-template
RUN mkdir -p /config/rclone

# Prepare the sync script
COPY /docker/sync-now.sh /
RUN chmod +x /sync-now.sh

# Configure fcron
# COPY /docker/fcron_builder.tab /tmp/
# RUN fcrontab -u builder /tmp/fcron_builder.tab

ENTRYPOINT ["fcron", "--foreground", "--firstsleep", "0"]
