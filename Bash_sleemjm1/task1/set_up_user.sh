#!/bin/bash

# Test script for setting up users with given params.
# Script will be used:	set_up_user $email $date
#		 ex:	set_up_user joe.sleeman@gmail.com 20/09/1990

email=$1
date=$2
name=${email%.*..}
last_name=${name#*.}
username=${last_name:0:3}${name:0:3}
password=$(echo $date | awk -F[/] '{print $3$2$1}')

echo "Username: $username"
echo "Password: $password"
