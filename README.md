# Automation_Backup
DevOps two bash scripts to make encrypted backup and restore it. 

# Backup and Restore Script

This bash script provides the functionality to perform automated backup and restore operations for directories and files.
It allows you to create encrypted backups and restore data from those backups.

## Features

- Automated backup of specified directories and files.
- Encryption of backups using GPG for data security.
- Restoration of encrypted backups.

## Usage

### Backup

To perform a backup, execute the script with the following parameters, and make sure that these parameters are valid:
./backup.sh backupDir storeDir encryptionKey numberOfDays

### Restore

To perform a restore, execute the script with the following parameters, also These parameters must be valid:
./restore.sh backupDir storeDir decryptionKey
