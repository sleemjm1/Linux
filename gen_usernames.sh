#!/bin/bash

# Testing to see if I can generate usernames

IFS=";"
user_count=0
file=$1

while read email date group shared
do
	if [ ! $email == "e-mail" ]
	then
		name=${email%.*..}
		last_name=${name#*.}
		username=${last_name:0:3}${name:0:3}
		if ! grep -i -q "${username}" /etc/passwd ;
		# if user not exist
		then
			((user_count+=1))	
		fi
	fi	
done < $file

echo "$user_count pending users"
