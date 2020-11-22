#!/bin/bash
#
# This script copies a file to the S3 bucket, which is then 
# downloaded from when building the Docker container.
#


# Errors are fatal
set -e

BUCKET="dmuth-splunk-lab"

if test ! "$1"
then
	echo "! "
	echo "! Syntax: $0 file_to_upload"
	echo "! "
	exit 1
fi

FILE=$1

echo "# "
echo "# Uploading file ${FILE} to S3 bucket '${BUCKET}'..."
echo "# "
aws s3 cp ${FILE} s3://${BUCKET}

echo "# Done!"


