#!/bin/bash

# Assignment One

URL=$1

if [ -z "$1" ]
# If a URL is not passed in
then
	echo "Please enter a URL "
	read URL
fi

filename='users.txt'

wget -O $filename $URL

IFS=";"

while read email date group shared
do
	if ! [[ $email == "e-mail" ]]
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
			if ! grep -i "${group}" /etc/group ;
			# If the group doesn't already exist
			then
				groupadd $group
				usermod -a -G $group $username
				echo "Created group and added user to group."
			else
				usermod -a -G $group $username
				echo "Group already exists. Adding user to group."
				echo ""
			fi
		else
			echo "The user already exists, not creating again..."
			echo ""
		fi
	fi
done < users.txt

