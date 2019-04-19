#!/bin/bash

# Errors are fatal
set -e

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

echo "# "
echo "# Building Docker container..."
echo "# "
docker build . -f Dockerfile-core -t splunk-lab-core
docker build . -t splunk-lab
docker build . -f Dockerfile-ml -t splunk-lab-ml

echo "# Done!"

