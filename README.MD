# Magento Backup Cron
A script to run magento backups

# Installation
- Download the script `wget https://raw.githubusercontent.com/alaa-almaliki/magento2-backup-cron/master/magento_backup_cron.sh`
- Change mode of the script to be executable `chmod +x magento_backup_cron.sh`
- Add cron entry, example: `0 1 * * * /bin/bash path/to/magento_backup_cron.sh`
# Documentation
Worth noting here is that the backup process sets the maintenance flag, so the site is not accessible during the backup process.

- The script can be placed in magento project root directory or any directory.
- If the script is decided to be placed in a directory different than magento root directory, then it needs to set in line 12 `# cd /path/to/magento`.
- Worth referring to the comments in the script for configuring the backup process.
- The script uses the magento default cli commands to backup.
- The script checks if the site is on maintenance mode, and if so it will exit.
- The script runs three backup areas db, media and code.
- The db and media are enabled by default, the code backup is disabled but can be enabled if needed.
- The backups are stored in home directory in `backup/{db, media, code}` directories.
- After the backup process is finished, old backup files are deleted as part of the cleanup.
- `BACKUP_TO_KEEP` is used to set how many backup files should remain. It is set to 3 by default but it can be increased or decreased if needed.