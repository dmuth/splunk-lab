#!/bin/bash

# Errors are fatal
set -e

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

#
# Remove this local/ symlink in case it happens to exist from 
# a previous run with devel.sh.  Otherwise, it will make it into
# the Dockerfile as /opt/splunk/etc/apps/splunk-lab/local
# and then mounting to it from a production run will cause an empty directory.
#
# This may cause unnessary rebuilds of intermediate images, but it's less awful
# then breaking prod. (And hopefully the builds will be cached)
#
rm -fv splunk-lab-app/local

#
# Download our packages from the Splunk Lab S3 bucket
#
./bin/download-from-s3.sh

echo "# "
echo "# Building Docker container..."
echo "# "
docker build . -f Dockerfile-core -t splunk-lab-core
docker build . -t splunk-lab
docker build . -f Dockerfile-ml -t splunk-lab-ml

echo "# "
echo "# Tagging Docker containers..."
echo "# "
docker tag splunk-lab dmuth1/splunk-lab
docker tag splunk-lab-ml dmuth1/splunk-lab-ml

echo "# Done!"

