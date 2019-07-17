#!/bin/bash
#
# Create sample logfiles with a single event each, so we can 
# test out how Splunk handles many files at startup.
#


# Errors are fatal
set -e

if test ! "$1"
then
	echo "! "
	echo "! Syntax: $0 num"
	echo "! "
	echo "! num - Number of logfiles to create"
	echo "! "
	exit 1
fi

NUM=$1

#
# Change to our logs directory
#
pushd $(dirname $0)/.. > /dev/null
mkdir -p logs
cd logs

echo "# "
echo "# Removing any previous test files..."
echo "# "
find . -name 'test-events-*' -delete

echo "# "
echo "# Creating ${NUM} new files..."
echo "# "
for I in $(seq -w $NUM)
do
	FILE=test-events-${I}.txt
	echo $FILE
	echo "Test event ${I}/$NUM" > $FILE
done

echo "# Done!"


