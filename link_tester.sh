#!/bin/bash

# link tester experiment

regex='(https?|ftpfile)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Aa-z0-9\+&@#?%=~_|]'

string=$1

if [ $string =~ $regex ]
then
	echo "Link valid"
else
echo
	echo "Link invalid"
fi
