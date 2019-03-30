#!/bin/bash
#
# Clean up after runnning an instance of Splunk Lab
#

CLEAN_DATA=""
CLEAN_LOGS=""

#
# Change to the parent directory of this script
#
pushd $(dirname $0) > /dev/null
cd ..

#
# Parse our args
#
if test "$1" == "data"
then
	CLEAN_DATA=1

elif test "$1" == "logs"
then
	CLEAN_LOGS=1

elif test "$1" == "all"
then
	CLEAN_DATA=1
	CLEAN_LOGS=1

else
	echo "! "
	echo "! Syntax: $0 ( data | logs | all )"
	echo "! "
	exit 1
fi


if test "$CLEAN_DATA"
then
	echo "# "
	echo "# Removing data/ directory..."
	echo "# "
	if test ! "$CLEAN_LOGS"
	then
		echo "# (This means logs will be reingested on the next run...)"
		echo "# "
	fi
	
	rm -rf data/

fi


if test "$CLEAN_LOGS"
then
	echo "# "
	echo "# Removing logs/ directory..."
	echo "# "

	rm -rf logs/

	echo "# "
	echo "# Creating empty logs/ directory..."
	echo "# "
	mkdir logs
	touch logs/empty.txt

fi

echo "# Done!"

