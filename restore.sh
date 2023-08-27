#!/bin/bash
source ./backup_restore_lib.sh


#accept parameters from user.
restoreDir=$1
destinationDir=$2
decryptionKey=$3


validate_restore_params $restoreDir $destinationDir $decryptionKey
restore
