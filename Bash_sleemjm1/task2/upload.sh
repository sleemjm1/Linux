#!/bin/bash

# A script that compresses a given folder and uploads it to a remote location.
# Use this script to submit assignment, as well as this script.

folder=$1
archive_name=$2
destination="sba@10.25.1.76:/SBAs/bash/subtest" # Hard-coded (yuck)
port=22000					# Hard-coded

if [ -z "$folder" ] || [ ! -d "$folder" ] 	# Check if user has entered folder, and if
						# that folder exists in our system.
then
	echo "Please enter an existing folder to be compressed and uploaded."
	read folder
fi

if [ -z "$archive_name" ] 			# Check if user has entered an archive name
then
	echo "Please enter a name for your archived folder. Has to end in .tar.gz"
	read archive_name
	# Could run regex check on $archive_name to make sure it ends in .tar.gz
fi

# Compress_folder function

compress_folder()
{
	l_folder=$1
	l_archive_name=$2
	
	if [ -d $l_folder ] # If the folder exists in our system.
	then
		tar -zcvf $l_archive_name $l_folder
	else
		echo "Folder you are trying to compress does not exist."
		echo "Please run script with valid folder name."
		echo ""
	fi
	
}

# Upload_archive function
# Params: archive_name, destination

upload_archive()
{
	l_archive_name=$1
	l_destination=$2
	l_port=$3

	scp -P $l_port $l_archive_name $l_destination
}

compress_folder $folder $archive_name 
upload_archive $archive_name $destination $port
