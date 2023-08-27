#!/bin/bash
source ./backup_restore_lib.sh


#accept parameters from user.
backupDir=$1
storeDir=$2
encryptionKey=$3
numberOFDays=$4

validate_backup_params $backupDir $storeDir $encryptionKey $numberOFDays
backup
