#!/bin/bash

# Errors are fatal
set -e

CACHE="cache"
BUILD="${CACHE}/build"

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

#
# Skip our building if NO_BUILD is set.
#
if test "$NO_BUILD"
then
	echo "# "
	echo "# Skipping build due to \$NO_BUILD specified..."
	echo "# "

else
	./bin/build.sh $@

	echo "# "
	echo "# Tagging container..."
	echo "# "
	docker tag splunk-lab dmuth1/splunk-lab
	docker tag splunk-lab-ml dmuth1/splunk-lab-ml

fi


SPLUNK_DEVEL=1 REST_KEY=${REST_KEY} SPLUNK_PASSWORD=${SPLUNK_PASSWORD:-password1} ./go.sh


