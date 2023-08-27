#!/bin/bash

date=$(date +"%d %m %Y" | sed "s/[[:space:]]/_/g")

#Backup parameters.
validate_backup_params (){

#Validate number of accepted parameters.
if [ $# -ne 4 ]
then
	echo "Error you need to enter 4 parameters: \"backup directory, store directory, encryption key and number of days\""
	exit 
fi

#Validate the directory that will be backed up.
if [ ! -d "$backupDir" ]
then
	echo "Please enter valid directory like \"/path/directory\" "
	exit
fi 

#check foundation of the directory that will store the backup.
if [ ! -d "$storeDir" ]
then
	mkdir -p  $storeDir
fi

# Validate the GPG key
output=$(gpg --list-keys "$encryptionKey" 2>&1)
if [[ $output == *"No public key" ]]
then
	echo "$output"
        echo "GPG key $encryptionKey is not valid, please enter valid one"
        echo "to create key try command : gpg --gen-key"
        exit
fi

echo "It takes few seconds, Backup loading..."

}

#Restore Parameters.
validate_restore_params (){

#Validate number of accepted parameters.
if [ $# -ne 3  ]
then
        echo "Error you need to enter 3 parameters: \"backup directory, store directory, decryption key\""
        exit
fi

#Validate the directory that will be used to restore data.
if [ ! -d "$restoreDir" ]
then
        echo "Please enter valid directory that contain the tar.gz.gpg file, like \"/path/directory\" "
        exit
fi

#check foundation of the directory that will store the backup.
if [ ! -d "$destinationDir" ]
then
        mkdir -p  $destinationDir
fi

#Validate the GPG key
output=$(gpg --list-keys "$decryptionKey" 2>&1)
if [[ $output == *"No public key" ]]
then
	echo "$output"
        echo "GPG key $decryptionKey is not valid, please enter valid one"
        echo "to create key try command : gpg --gen-key"
        exit
fi

echo "It takes few seconds, Restore loading..."

}


#Backup function.
backup (){
#Searching for any subdirectory in the directory that entered by user to be backedup.
for dir in "$backupDir"/*
do
	if [ -d "$dir" ]
	then
		dirName=$(basename "$dir")
		lastDirName="${storeDir}/${dirName}_$date.tar.gz"	
		tar czf "$lastDirName" -C ${backupDir} . 
   		echo "Directory '$dirName' backed up"
		gpg --recipient $encryptionKey --output "$lastDirName".gpg --encrypt ${lastDirName}
		rm -f $lastDirName

	fi
done	
	
#Searching for any file that changed in numberOFDays in directory that entered by user to be backedup.
for file in $(find ${backupDir} -maxdepth 1 -type f -mtime -$numberOFDays )
do
	if [ -f "$file" ]
	then
        	fileName=$(basename "$file")
		lastFileName="${storeDir}/${fileName}_${date}.tar.gz"
		tar czf $lastFileName -C $backupDir $fileName
	        echo "File '$fileName' backed up"
		gpg --recipient $encryptionKey --output ${lastFileName}.gpg --encrypt ${lastFileName}
		rm -f $lastFileName
	fi
done

#After make compressed tar file in directory, creating one file encrypted of directory needed to be backedup.
file="${storeDir}_${date}.tar.gz"
tar czf $file  $storeDir
variable=${file}.gpg
gpg --recipient $encryptionKey --output ${variable} --encrypt ${file}
rm -f $file
rm -r $storeDir

#You must add remote server and remote path here and unhash the next 3 lines to upload your data to server and delete file localy.
#remoteServer="ec2-user@ip"
#remotePath="/path/to/store.gpg/file"
#scp -i "/path/to/key.pem" "$variable" "$remoteServer:$remotePath"
#rm -r $variable
}


#Restore Function
restore (){

#Searching for any subdirectory in the directory that entered by user to betored.
for file in ${restoreDir}/*.gpg
do
	tarFileName=$(basename ${file} .gpg)	
	gpg --recipient $decryptionKey --output $tarFileName --decrypt ${file}
	tar xzf $tarFileName -C $destinationDir
	rm -f $tarFileName
	dir=$(ls $destinationDir)
	
done

#Searching for any file that will be restored.
for file in ${destinationDir}/${dir}/*.gpg
do
	tarFile=$(basename ${file} .gpg)
	gpg --recipient $decryptionKey --output ${destinationDir}/${dir}/$tarFile --decrypt ${file}
	tar xzf ${destinationDir}/${dir}/$tarFile -C $destinationDir/${dir}
	rm -f ${destinationDir}/${dir}/$tarFile
	rm -f $file
done

}

