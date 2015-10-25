						README FILE

Inside this folder, you will see two sub-directories: task1, and task2. Inside these sub-directories are 
a series of scripts used to complete the tasks for this assignment.

						- - - 

task1:

There are 3 files & 1 sub-directory in this directory. The directory is named test_files, and has a bunch
of simple bash scripts that I used when experimenting with creating various functions within the main 
bash_assignment script. These scripts are not important as they were just used for testing purposes. So
I am not going to describe what they do. If you are interested, there are comments explaining the scripts 
in the scripts themselves.

Below is a brief description of the files in the task1 directory:


bash_assignment.sh:

The main assignment script, this has all of the code required to set up a bunch of users and passwords,
as well as their shared directories and permissions.

This script can be passed in parameters, and if it doesn't recieve these parameters, it will prompt the user
to input them. This script must be run with sudo prefix, or it will simply not work because it doesn't
have correct permissions. 

Example way to run the script: sudo bash bash_assignment www.kate.ict.op.ac.nz/~sleemjm1/linus/users.txt

After running the script, it will see if the users from the CSV are already in our system or not. It will
then prompt the user with the amount of pending users, and ask them if they want to set proceed with 
setting up those users. If the user does want to proceed, it will then create the users and passwords
which are specified in the CSV. It will print to the console the usernames, passwords, as well as the groups
that each user will be added to.


delete_users.sh:

This script is very useful for testing purposes, as it will loop through the text file "users.txt" and remove
each user from the system as well as their corresponding home directories. It will then print to the console
who it is deleting. This script requires sudo prefix.

Example way to run the script: sudo bash delete_users.sh


users.txt:

This is a CSV file which has the information for our users that we wish to generate. This file is created
or overwritten by the main bash_assignment.sh script if the script is not run on users.txt. You can inspect
this file if you want to see the structure of the CSV, or information related to the users in the system.


						- - - 

task2:

There is only 1 file in this directory, and it is the script which is used to compress & upload a directory
to a hard-coded destination. You can pass it in the folder you with and the name you want to give the archive,
or, the script will prompt you to enter them. This script makes use of the tar command, as well as the scp
command in order to copy the directory across to the destination. This script requires sudo prefix.

Example way to run the script: sudo bash upload.sh /home/joe/Bash_sleemjm1 bash_sleemjm1.tar.gz
