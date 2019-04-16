#!/bin/bash

# Errors are fatal
set -e

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

echo "# "
echo "# Tagging containers..."
echo "# "
docker tag splunk-lab dmuth1/splunk-lab
docker tag splunk-lab-ml dmuth1/splunk-lab-ml

echo "# "
echo "# Pushing containers to Docker Hub..."
echo "# "
docker push dmuth1/splunk-lab
docker push dmuth1/splunk-lab-ml


echo "# Done!"

