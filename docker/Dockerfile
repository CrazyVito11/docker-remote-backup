FROM rclone/rclone:1.68.2

USER root

# Update the local package cache and install dependencies
RUN apk update
RUN apk add fcron bash envsubst curl

# Prepare the sync script
COPY /docker/sync-now.sh /
RUN chmod +x /sync-now.sh

# Prepare environment settings
RUN mkdir /config
RUN env > /config/base.env
COPY .env /config/user.env

# Prepare the rclone configuration
COPY /rclone /config/rclone-template
RUN mkdir /config/rclone
RUN bash -c "set -o allexport; source /config/user.env; bash /config/rclone-template/generate-rclone-conf.sh /config/rclone-template/rclone.conf > /config/rclone/rclone.conf"

# Configure fcron
RUN bash -c 'set -o allexport; source /config/user.env; echo "$BACKUP_CRON_INTERVAL bash -c \"set -o allexport; source /config/base.env; source /config/user.env; /sync-now.sh\" >> /tmp/cron.log 2>&1" > /tmp/fcron.tab'
RUN fcrontab /tmp/fcron.tab


ENTRYPOINT ["fcron", "--foreground", "--firstsleep", "0"]
