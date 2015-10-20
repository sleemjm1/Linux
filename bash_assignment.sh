#!/bin/bash

# Assignment One

URL=$1

if [ -z "$1" ]
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
	then
		# setting up variables
		name=${email%.*..}
		last_name=${name#*.}
		username=${last_name:0:3}${name:0:3}
		password=$(echo $date | awk -F[/] '{print $3$2$1}')

		if ! grep -i "${username}" /etc/passwd ;
		then
			crypt_password=$(perl -e 'print crypt($ARGV[0], "password")' $password)
			useradd -d /home/$username -m -s /bin/bash -p$crypt_password $username
			# need to work out how to add password to user
			echo "The user has been added."
			echo ""
                        echo "Password: $password"
		else
			echo "The user already exists, not creating again..."
			echo ""
		fi
	fi
done < users.txt

