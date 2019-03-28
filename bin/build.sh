#!/bin/bash

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

echo "# "
echo "# Building Docker container..."
echo "# "
docker build . -t splunk-lab

echo "# Done!"

