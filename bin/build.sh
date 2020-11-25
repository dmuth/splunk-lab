#!/bin/bash

# Errors are fatal
set -e

CACHE="cache"
DEPLOY="${CACHE}/deploy"
BUILD="${CACHE}/build"

SPLUNK_PRODUCT="splunk"
SPLUNK_HOME="/opt/splunk"
SPLUNK_VERSION="8.1.0.1"
SPLUNK_BUILD="24fd52428b5a"
SPLUNK_FILENAME="splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz"
SPLUNK_URL="https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}"
CACHE_FILENAME="${CACHE}/${SPLUNK_FILENAME}"

#
# This is set to true if we build even a single container, and subsequent
# containers will ignore the build file and instead force being built.
#
BUILDING=""

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..


function print_syntax() {
	echo "! "
	echo "! Syntax: $0 [ --force ]"
	echo "! "
	echo "! --force force rebuilding of cached containers"
	echo "! "
	exit 1
} # print_syntax()


if test "$1" == "-h" -o "$1" == "--help"
then
	print_syntax

elif test "$1" == "--force"
then
	echo "# Removing build files..."
	rm -fv ${BUILD}/*

elif test "$1"
then
	print_syntax

fi

#
# Download and cache local copy of Splunk to speed up future builds.
#
mkdir -p ${CACHE} ${DEPLOY} ${BUILD}

#ls -ltrh $CACHE # Debugging
if test ! -f "${CACHE_FILENAME}"
then
	echo "# "
	echo "# Caching copy of ${SPLUNK_FILENAME}..."
	echo "# "
	wget -O ${CACHE_FILENAME} ${SPLUNK_URL}
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


DOCKER="0-0-core"
if test ${BUILD}/${DOCKER} -nt docker/${DOCKER}
then
	echo "# File '${BUILD}/${DOCKER}' is newer than our Dockerfile, we don't need to build anything!"
else
	BUILDING=1
fi

if test "${BUILDING}"
then
	docker build . -f docker/${DOCKER} -t splunk-lab-core-0
	touch ${BUILD}/${DOCKER}
fi


DOCKER="0-1-splunk"
if test ${BUILD}/${DOCKER} -nt docker/${DOCKER}
then
	echo "# File '${BUILD}/${DOCKER}' is newer than our Dockerfile, we don't need to build anything!"
else
	BUILDING=1
fi

if test "${BUILDING}"
then
	ln -f ${CACHE}/splunk-8.1.0.1-24fd52428b5a-Linux-x86_64.tgz ${DEPLOY} 
	docker build \
		--build-arg SPLUNK_HOME=${SPLUNK_HOME} \
		--build-arg CACHE_FILENAME=${DEPLOY}/${SPLUNK_FILENAME} \
		. -f docker/${DOCKER} -t splunk-lab-core-1
	rm -f ${DEPLOY}/*
	touch ${BUILD}/${DOCKER}
fi


DOCKER="0-2-apps"
if test ${BUILD}/${DOCKER} -nt docker/${DOCKER}
then
	echo "# File '${BUILD}/${DOCKER}' is newer than our Dockerfile, we don't need to build anything!"
else
	BUILDING=1
fi

if test "${BUILDING}"
then
	ln -f ${CACHE}/syndication-input-rssatomrdf_124.tgz ${DEPLOY} 
	ln -f ${CACHE}/wordcloud-custom-visualization_111.tgz ${DEPLOY} 
	ln -f ${CACHE}/slack-notification-alert_203.tgz ${DEPLOY} 
	ln -f ${CACHE}/splunk-dashboard-examples_800.tgz ${DEPLOY} 
	ln -f ${CACHE}/eventgen_720.tgz ${DEPLOY} 
	ln -f ${CACHE}/rest-api-modular-input_198.tgz ${DEPLOY} 
	docker build \
		--build-arg DEPLOY=${DEPLOY} \
		. -f docker/${DOCKER} -t splunk-lab-core
	rm -f ${DEPLOY}/*
	touch ${BUILD}/${DOCKER}

fi

DOCKER="1-splunk-lab"
if test ${BUILD}/${DOCKER} -nt docker/${DOCKER}
then
	echo "# File '${BUILD}/${DOCKER}' is newer than our Dockerfile, we don't need to build anything!"
else
	BUILDING=1
fi

if test "${BUILDING}"
then
	docker build . -f docker/${DOCKER} -t splunk-lab
	touch ${BUILD}/${DOCKER}
fi


DOCKER="1-splunk-lab-ml"
if test ${BUILD}/${DOCKER} -nt docker/${DOCKER}
then
	echo "# File '${BUILD}/${DOCKER}' is newer than our Dockerfile, we don't need to build anything!"
else
	BUILDING=1
fi

if test "${BUILDING}"
then
	ln -f ${CACHE}/python-for-scientific-computing-for-linux-64-bit_202.tgz ${DEPLOY} 
	ln -f ${CACHE}/splunk-machine-learning-toolkit_520.tgz ${DEPLOY} 
	ln -f ${CACHE}/nlp-text-analytics_102.tgz ${DEPLOY} 
	ln -f ${CACHE}/halo-custom-visualization_113.tgz ${DEPLOY} 
	ln -f ${CACHE}/sankey-diagram-custom-visualization_130.tgz ${DEPLOY} 
	docker build \
		--build-arg DEPLOY=${DEPLOY} \
		. -f docker/${DOCKER} -t splunk-lab-ml
	rm -f ${DEPLOY}/*
	touch ${BUILD}/${DOCKER}

fi

echo "# "
echo "# Tagging Docker containers..."
echo "# "
docker tag splunk-lab dmuth1/splunk-lab
docker tag splunk-lab-ml dmuth1/splunk-lab-ml

echo "# Done!"

