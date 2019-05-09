#!/bin/bash

# Errors are fatal
set -e

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

./bin/build.sh

echo "# "
echo "# Tagging container..."
echo "# "
docker tag splunk-lab dmuth1/splunk-lab
docker tag splunk-lab-ml dmuth1/splunk-lab-ml

SPLUNK_DEVEL=1 REST_KEY=${REST_KEY} SPLUNK_PASSWORD=${SPLUNK_PASSWORD:-password1} ./go.sh


