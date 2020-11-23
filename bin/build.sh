#!/bin/bash

# Errors are fatal
set -e

CACHE="splunk-package-cache"

SPLUNK_PRODUCT="splunk"
SPLUNK_HOME="/opt/splunk"
SPLUNK_VERSION="8.1.0.1"
SPLUNK_BUILD="24fd52428b5a"
SPLUNK_FILENAME="splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz"
SPLUNK_URL="https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}"
CACHE_FILENAME="${CACHE}/${SPLUNK_FILENAME}"
CACHE_TMP="${CACHE}/tmp"

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

#
# Download and cache local copy of Splunk to speed up future builds.
#
mkdir -p ${CACHE}

#ls -ltrh $CACHE # Debugging
if test ! -f "${CACHE_FILENAME}"
then
	echo "# "
	echo "# Caching copy of ${SPLUNK_FILENAME}..."
	echo "# "
	wget -O ${CACHE_TMP} ${SPLUNK_URL}
	mv ${CACHE_TMP} ${CACHE_FILENAME}
fi


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
echo "# Building Docker containers..."
echo "# "

docker build . -f docker/0-0-core -t splunk-lab-core-0
docker build \
	--build-arg SPLUNK_HOME=${SPLUNK_HOME} \
	--build-arg CACHE_FILENAME=${CACHE_FILENAME} \
	. -f docker/0-1-splunk -t splunk-lab-core-1
docker build . -f docker/0-2-apps -t splunk-lab-core

docker build . -f docker/1-main -t splunk-lab

docker build . -f docker/ml -t splunk-lab-ml

echo "# "
echo "# Tagging Docker containers..."
echo "# "
docker tag splunk-lab dmuth1/splunk-lab
docker tag splunk-lab-ml dmuth1/splunk-lab-ml

echo "# Done!"

