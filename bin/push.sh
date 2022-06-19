#!/bin/bash

# Errors are fatal
set -e

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..


#
# Print up our syntax and exit.
#
function print_syntax() {

	echo "! "
	echo "! Syntax: $0 MAJOR MINOR"
	echo "! "
	echo "! MAJOR - Major version number of Splunk, to be used tagging Docker containers (e.g. 8)"
	echo "! MINOR - Minor version number of Splunk (e.g. 8.2.6)"
	echo "! "
	exit 1

} # End of print_syntax()


if test "$1" == "-h" -o "$1" == "--help"
then
	print_syntax

elif test ! "$2"
then
	print_syntax

fi

MAJOR=$1
MINOR=$2

re="^[0-9]+$"
if ! [[ "${MAJOR}" =~ ${re} ]]
then
	echo "! "
	echo "! $0: Version ${MAJOR} is not a number!"
	echo "! "
	exit 1
fi

re="^[0-9\.]+$"
if ! [[ "${MINOR}" =~ ${re} ]]
then
	echo "! "
	echo "! $0: Version ${MINOR} is not a number!"
	echo "! "
	exit 1
fi


echo "# "
echo "# Tagging containers..."
echo "# "
docker tag splunk-lab dmuth1/splunk-lab
docker tag splunk-lab dmuth1/splunk-lab:${MAJOR}
docker tag splunk-lab dmuth1/splunk-lab:${MINOR}
docker tag splunk-lab-ml dmuth1/splunk-lab-ml
docker tag splunk-lab-ml dmuth1/splunk-lab-ml:${MAJOR}
docker tag splunk-lab-ml dmuth1/splunk-lab-ml:${MINOR}

echo "# "
echo "# Pushing containers to Docker Hub..."
echo "# "
docker push dmuth1/splunk-lab
docker push dmuth1/splunk-lab:${MAJOR}
docker push dmuth1/splunk-lab:${MINOR}
docker push dmuth1/splunk-lab-ml
docker push dmuth1/splunk-lab-ml:${MAJOR}
docker push dmuth1/splunk-lab-ml:${MINOR}


echo "# Done!"

