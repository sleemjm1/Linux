#!/bin/bash

# Assignment One

# To do:
#	! Regex checking on URI
#	! Count pending users (not sure how complex this has to be)
#	* Groups (maybe not right)
#	! Uploading
#	! Textfile
#	! Links
#	! Errors + feedback to user 
#	! Alias - all users - off (systemctl poweroff)
#	! Log file
#	! Shared folder permissions
#	! Functions

URL=$1
IFS=";"
filename='users.txt'

if [ -z "$1" ]
# If a URL is not passed in
then
	echo "Please enter a URL "
	read URL
fi

wget -O $filename $URL

pending_users()			# Function for counting pending users.
{
	local user_count=0
	while read email date group shared
	do
		if [ ! $email == "e-mail" ]
		then
			name=${email%.*..}
			last_name=${name#*.}
			username=${last_name:0:3}${name:0:3}

			if [ ! grep -i -q "${username}" /etc/passwd ] ;
			then
				((user_count+=1))
			fi
		fi
	done < $filename
	return $user_count	
}

while read email date group shared
do
	if ! [[ $email == "e-mail" ]] ;
	# checking to see if the entry is the "header" of the CSV
	then
		# setting up variables
		name=${email%.*..}
		last_name=${name#*.}
		username=${last_name:0:3}${name:0:3}
		password=$(echo $date | awk -F[/] '{print $3$2$1}')

		if ! grep -i "${username}" /etc/passwd ;
		# If the user doesn't already exist
		then
			crypt_password=$(perl -e 'print crypt($ARGV[0], "password")' $password)
			useradd -d /home/$username -m -s /bin/bash -p$crypt_password $username
			chage -d 0 $username	# Force user to change password on next log in
			echo "$username has been added."
			echo ""
                        echo "Password: $password" #Testing purposes
			
			# Groups are tricky. Sometimes, a user will belong to more than one group.
			# Sometimes, a user will not belong to a group at all. We will try to account for
			# this with the following code.

			# - Check if we are in group field & if the group field is not empty. 
			# - Change IFS to "," because in our CSV, groups are seperated by commas.
			# - Iterate through $group, checking to see if the group exists.
			# - If the group does not exist, create the group.
			# - Add the user to their group(s).
			# - Finally, change IFS back to ";" so that we can resume iterating through CSV.

			if [ $group ] && ! [ -z $group ] ;
			# if we are in group field & the field is not empty
			then
				IFS=","
				for i in $group
				do
					if ! grep -i "${i}" /etc/group ;
					# if the group doesn't already exist
					then
						groupadd $i
						echo "$i is being created."
					fi
					usermod -a -G $i $username
					echo "Adding $username to $i"
				done				
				IFS=";"
			fi
		else
			echo "The user already exists, not creating again..."
			echo ""
		fi
		
		if [ ! -d $shared ]
		then
			mkdir $shared
			echo "Creating directory: $shared"		
		fi
		
	fi
done < $filename

