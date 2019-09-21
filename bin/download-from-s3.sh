#!/bin/bash
#
# This script downloads our Splunk packages from the Splunk Lab S3 
# bucket that I created.  That bucket is set to "Requestor Pays",
# so that people building their own copies don't drive up my AWS bill. :-)
#


# Errors are fatal
set -e

# Change to our parent directory
pushd $(dirname $0)/.. > /dev/null

mkdir -p splunk-packages-from-s3
pushd splunk-packages-from-s3 >/dev/null

echo "# "
echo "# Downloading packages from S3..."
echo "# "
aws s3 sync s3://dmuth-splunk-lab/ .



