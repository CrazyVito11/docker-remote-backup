# Docker Remote Backup
Automatically mirrors an encrypted version of a directory to a remote SFTP server via [Rclone](https://rclone.org/).


## Setup
### Container
1. Copy `.env.example` and call it `.env`
2. Fill in `.env`
3. Create the directories beforehand with `mkdir ./logs; mkdir ./backup_dir`
4. Start the Docker Compose project with `docker compose up -d --build`

It should now be ready to create backups for you!

> [!WARNING]
> Make sure you store the configured password and salt in a secure place like a password manager, as without those, your backups will be ***useless***!

> [!TIP]
> If you make a configuration change, don't forget to down and up the container again.
>
> `docker compose down && docker compose up -d`


### Remote (backup server)
The configuration steps that are needed will depend on what kind of machine the remote server is, but it will need to fulfill these requirements:

1. Needs to run a SFTP server. _(Shell access is not required)_
2. A backup user has been made with username + password authentication.
3. The backup directory has nothing else inside it.
4. The backup user has read and write access to the backup directory.


## Creating/restoring backups
### Create backup at remote
***TODO:** Add section that tells them it automatically creates the backup based on a CRON schedule*

#### Make backup immediately
If you want to make the backup immediately, you can use the following command:
```bash
docker compose exec docker-remote-backup bash /sync-now.sh
```


### Restore from remote backup
If you want to browse and/or download files from the remote backup, you can use the following command to start a WebDav server:

```bash
docker compose exec docker-remote-backup rclone serve webdav remote_backup:/ --addr 127.0.0.1:8080 --read-only
```

You should now be able to browse and download files using a webbrowser or a WebDav client _([WinSCP](https://winscp.net/eng/index.php) or [Dolphin](https://apps.kde.org/dolphin/) via `webdav://127.0.0.1:8080`)_.

> [!NOTE]
> For safety reasons, this WebDav server will only be reachable from the host machine (`127.0.0.1:8080`) and is _read-only_ to prevent accidental damage.
>
> If you want to make it accessible from the network while staying secure, replace `--addr 127.0.0.1:8080` with `--addr :8080 --user "admin" --pass "s0mething_SECURE"`.

> [!WARNING]
> If you are restoring from another machine that wasn't originally hosting this container, you will also have to make sure you use the same `.env` credentials.
>
> **NEVER** run `sync-now.sh` or any other Rclone command in this state, as you can risk damaging your remote backup!


## Tips
### Obfuscate passwords
Credentials to connect or encrypt the data need to be obfuscated before they can be used.

> [!WARNING]
> As noted by the Rclone documentation, passwords are obfuscated to make it a bit more difficult to get, but they aren't fully protected!

To obfuscate a password, run the following command:

`docker compose exec docker-remote-backup rclone obscure "your-plain-text-password"`

The output of this command can now be used.


### Run script during specific events
You have the ability to run your own Bash scripts at certain events, this can allow you to for example send notifications in case the sync completes or fails.

A couple of examples have been provided in the `hooks` directory.

| Event            | Script name         | Description                                                        |
|------------------|---------------------|--------------------------------------------------------------------|
| Backup success   | `backup-success.sh` | Executed when the RClone command successfully finishes.            |
| Backup failure   | `backup-failure.sh` | Executed when the RClone command ran against some kind of error.   |
| Lock file exists | `lock-present.sh`   | Executed when the lock file exists, indicating it's still syncing. |


### Symlinks inside backup directory
If you have a bunch of projects and/or you just want to store a portion of it _(data without the application itself for example)_, then you can make a backup directory that contains relative symlinks to the actual data.

You can achieve this by setting the `SOURCE_CONTEXT_DIRECTORY` to a directory that has both the backup directory and the destination of the symlinks.
Once you've done that, you can set `SOURCE_DIRECTORY` to the path of the backup directory, relative to the context directory.

The container will resolve the symlinks while it's creating the backup.

> [!WARNING]
> It's important to keep in mind that you need to have the right context configured and that you only use relative symlinks.
>
> Using full path symlinks or a wrong context will cause the container to not be able to resolve the symlinks.

> [!TIP]
> If your projects are spread out over multiple drives, it's recommended to just configure multiple instances of this container, one for each drive.
>
> It's not recommended to try and mount the root filesystem in the container.


#### Example
In this example we want to make a backup of the `data` directory of each project in the user's home directory.
So we make a relative symlink to the data directory of each project, and store that inside `backup`.

Because we need to mount a directory in the container that has both the `backup` directory and the destination of the symlinks, we will configure the context directory to be `/home/example_user`.

We will then make a backup of the `/backup` directory, which will be a relative path to the context directory.

```
/home/example_user/
├── projects/
│   ├── project1/
│   │   ├── README.md
│   │   └── data/
│   ├── project2/
│   │   ├── README.md
│   │   └── data/
│   └── project3/
│       ├── README.md
│       └── data/
├── backup/
│   ├── project1 -> ../projects/project1/data
│   ├── project2 -> ../projects/project2/data
│   └── project3 -> ../projects/project3/data
```

And inside the `.env` file, the following configuration has been used.

| Configuration              | Value                |
|----------------------------|----------------------|
| `SOURCE_CONTEXT_DIRECTORY` | `/home/example_user` |
| `SOURCE_DIRECTORY`         | `/backup`            |
