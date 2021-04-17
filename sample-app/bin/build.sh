#!/bin/bash
#
# Build our sample Splunk app based on Splunk Lab.
#

# Errors are fatal
set -e

#
# Change to this script's parent directory
#
pushd $(dirname $0) > /dev/null
cd ..

docker build -t splunk-lab-sample-app .


