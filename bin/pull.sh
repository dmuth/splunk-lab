#!/bin/bash

# Errors are fatal
set -e

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

echo "# "
echo "# Pulling containers from Docker Hub..."
echo "# "
docker pull dmuth1/splunk-lab
docker pull dmuth1/splunk-lab-ml

echo "# "
echo "# Tagging containers..."
echo "# "
docker tag dmuth1/splunk-lab splunk-lab
docker tag dmuth1/splunk-lab-ml splunk-lab-ml


echo "# Done!"

