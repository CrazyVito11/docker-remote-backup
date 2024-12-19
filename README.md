# Docker Remote Backup
Automatically mirrors a directory to a remote location via `rclone` running in Docker


## Setup
***TODO:** document this*


## Restore from remote backup
***TODO:** document steps on how to restore the files from the remote server*


## Tips
### Obfuscate passwords
Credentials to connect or encrypt the data need to be obfuscated before they can be used.

> [!WARNING]
> The passwords are obfuscated to make it a bit more difficult to get, but they aren't fully protected!

To obfuscate a password, run the following command:

`docker compose exec docker-remote-backup rclone obscure "your-plain-text-password"`

The output of this command can now be used.
