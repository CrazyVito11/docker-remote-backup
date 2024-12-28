FROM rclone/rclone:1.68.2

USER root
COPY .env /tmp/.env

# Update the local package cache and install dependencies
RUN apk update
RUN apk add fcron bash envsubst curl

# Prepare the rclone configuration
COPY /rclone /config/rclone-template
RUN mkdir -p /config/rclone
RUN bash -c "set -o allexport; source /tmp/.env; bash /config/rclone-template/generate-rclone-conf.sh /config/rclone-template/rclone.conf > /config/rclone/rclone.conf; set +o allexport"

# Prepare the sync script
COPY /docker/sync-now.sh /
RUN chmod +x /sync-now.sh

# Configure fcron
# COPY /docker/fcron_builder.tab /tmp/
# RUN fcrontab -u builder /tmp/fcron_builder.tab

# Remove the temporary .env file
RUN rm /tmp/.env

ENTRYPOINT ["fcron", "--foreground", "--firstsleep", "0"]
