#!/bin/bash

# Joe Sleeman, October, 2015 

# Assignment One

# To do:
#	! Regex checking on URI => PARTIALLY COMPLETE
#	! Count pending users (not sure how complex this has to be) => COMPLETE
#	* Groups (maybe not right) => COMPLETE
#	! Uploading
#	! Textfile
#	! Links
#	! Errors + feedback to user 
#	! Alias - all users - off (systemctl poweroff)	=> PROVING DIFFICULT
#	! Log file => COMPLETE
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

#wget -O $filename $URL

# Functions begin

# Checking for a valid .txt URI. Then check for if this is a local file, or if we
# will need to use wget to download the file. This is not as robust as it could be,
# it is difficult to find a good regex for checking valid URLs
# Params: URI

check_regex()
{
	regex="(\w+)\.(txt$)" 	# Check to see if URI ends in ".txt"
	URI=$1

	if [[ "$URI" =~ $regex ]]
	then
		# True
		return 0
	else
		# False
		return 1
	fi
}

# Setting up CSV - Is the URI a file on our system, or is it a URL that we will
# need to use wget on?
# Params: URI, filename
# Returns: filename of CSV 

set_up_csv()
{
	local l_URI=$1
	local l_filename=$2

	if [ -e $l_URI ]	 # If this is a file on our system
	then
		echo $l_URI
	else			 # It must be a URL, use wget
		wget -O $l_filename $l_URI
		echo $l_filename
	fi
}

# pending_users() will count the pending and return that value

pending_users()			
{
	local l_user_count=0
	while read email date group shared
	do
		if [ ! $email == "e-mail" ]
		then
			l_name=${email%.*..}
			l_last_name=${l_name#*.}
			l_username=${l_last_name:0:3}${l_name:0:3}

			if ! grep -i -q "${l_username}" /etc/passwd ;
			then
				((l_user_count+=1))
			fi
		fi
	done < $filename
	return $l_user_count	
}

# add_user() function: Pass in username, password - order matters: add_user($username, $password)

add_user()		
{
	local l_username=$1
	local l_password=$2

	local crypt_password=$(perl -e 'print crypt($ARGV[0], "password")' $l_password)
	useradd -d /home/$l_username -m -s /bin/bash -p $crypt_password $l_username
	chage -d 0 $username 	# Force user to change password on next log in
	echo "$l_username has been added."
	echo "With password: $l_password"
}

# set_up_username will set up a user's username from their email
# set_up_username($email)

set_up_username() 
{
	local l_name=${1%.*..}
	local l_last_name=${l_name#*.}
	local l_username=${l_last_name:0:3}${l_name:0:3}
	
	echo $l_username
}

# set_up_password will set up a user's password

set_up_password()
{
	local l_date=$1
	local l_password=$(echo $l_date | awk -F[/] '{print $3$2$1}')
	
	echo $l_password
}

# check_user_exists will check if a user already exists in /etc/passwd
# pass in username

check_user_exists()
{
	l_username=$1
	if ! grep -i -q "${l_username}" /etc/passwd  ;
	then
		# 0 = true
		return 0
	else
		# 1 = false
		return 1
	fi
}

# Create alias off that allows powering off without entering an password
# (systemctl poweroff). Loaded upon every login.
# Params: $username 
set_up_alias()	#ToDo !!! NOT WORKING !!!
{
	local l_username=$1
	echo alias off="systemctl poweroff" >> /home/$l_username/.bashrc
}

# Add group will create a group if it doesn't already exist, and add the
# specified user to that group
# Paramaters: $group $username

add_group()
{
	l_group=$1
	l_username=$2

	if ! grep -i -q "${l_group}" /etc/group ;
	# if the group doesn't already exist
	then
		groupadd $l_group
		echo "$l_group is being created."	
	fi
	usermod -a -G $l_group $l_username
	echo "Adding $l_username to group: $l_group"	
}

# Log the success/failure of user creation to /log.txt
# Include date information that indicates the script runtime
# Params: username, creation_status

log_creation()
{
	l_username=$1
	l_creation_status=$2
	l_date=$(date)
	if [[ $l_creation_status == 1 ]]
	then
		echo $l_date: creation for $l_username was a success >> /log.txt
	else
		echo $l_date: creation of user failed >> /log.txt
	fi	
}


# End of functions

check_regex $URL
regex_result=$?

if [[ $regex_result == 0 ]]
then	# Our URL has passed the regex test
	filename=$(set_up_csv $URL $filename)
else	# Our URL has not passed the regex test
	echo "Invalid URL/Filename. Shutting down script."
	echo ""
	exit 1
fi

pending_users
pending_count=$?

echo "There is currently $pending_count pending user(s)"
echo "Proceed to create user(s)? y/n"
read confirmation

if [[ $confirmation == "y" ]] ;
then
	printf "\033c" # Clear terminal screen
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "										"
	echo "			Generating $pending_count new user(s)...		"
	echo "										"
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

	while read email date group shared
	do
		if ! [[ $email == "e-mail" ]] ;
		# checking to see if the entry is the "header" of the CSV
		then
			username=$(set_up_username $email)	
			
			echo ""
			echo -n "User:"
			echo $username
			echo "= = = = = = = = = = = = = = = "

			password=$(set_up_password $date)
		
			check_user_exists $username
			user_existance=$?
			
			if [[ $user_existance == 0 ]] ;
			# If our user doesn't already exist
			then
				add_user $username $password
				creation_status=1
				log_creation $username $creation_status
				
				# Groups are tricky. Sometimes, a user will belong to more than one group.
				# Sometimes, a user will not belong to a group at all. We will try to account
				# for this with the following code.
	
				# - Check if we are in group field & if the group field is not empty. 
				# - Change IFS to "," because in our CSV, groups are seperated by commas.
				# - Iterate through $group, checking to see if the group exists.
				# - If the group does not exist, create the group.
				# - Add the user to their group(s).
				# - Finally, change IFS back to ";" so that we can resume iterating through CSV
				# - NOTE: Much if this process is now done in the add_group function. 
	
				if [ $group ] && ! [ -z $group ] ;
				# if we are in group field & the field is not empty
				then					
					IFS=","
					for i in $group
					do
						add_group $i $username 
					done				
					IFS=";"
					echo "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
				fi
			else
				creation_status=0
				log_creation $creation_status $username
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
fi

echo ""
echo "Thank you for using Joe's script! :~)  "
