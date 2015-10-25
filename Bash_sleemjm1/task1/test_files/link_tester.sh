#!/bin/bash

# link tester experiment

regex="(\w+)\.(txt$)"

URL=$1

if [[ "$URL" =~ $regex ]]
then
	echo "Link valid"
else
echo
	echo "Link invalid"
fi

if [ ! -e $URL ]
then
	echo "This is a web URL"
else
	echo "This is a local file"
fi
