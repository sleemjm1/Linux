#!/bin/bash

# This file will delete all users from the URL provided

filename='users.txt'
IFS=";"

while read email date group shared
do
	if ! [[ $email == "e-mail" ]]
	then
		#setting up variables
		name=${email%.*..}
                last_name=${name#*.}
                username=${last_name:0:3}${name:0:3}
		
		if [ -z "$username" ]
		then
			echo "No such user exists."
		else
			echo "Deleting user: $username"
			userdel -rf $username
		fi
	fi
done < users.txt
	
