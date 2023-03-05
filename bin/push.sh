#!/bin/bash

# Errors are fatal
set -e

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..


# Load our variables
. ./bin/lib.sh


echo "# "
echo "# Pushing containers to Docker Hub..."
echo "# "
docker push dmuth1/splunk-lab
docker push dmuth1/splunk-lab:${SPLUNK_VERSION_MAJOR}
docker push dmuth1/splunk-lab:${SPLUNK_VERSION_MINOR}
docker push dmuth1/splunk-lab-ml
docker push dmuth1/splunk-lab-ml:${SPLUNK_VERSION_MAJOR}
docker push dmuth1/splunk-lab-ml:${SPLUNK_VERSION_MINOR}


echo "# Done!"

