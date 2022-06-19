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
	echo "! Syntax: $0 VERSION"
	echo "! "
	echo "! VERSION - Major version number of Splunk, to be used tagging Docker containers"
	echo "! "
	exit 1

} # End of print_syntax()


if test "$1" == "-h" -o "$1" == "--help"
then
	print_syntax

elif test ! "$1"
then
	print_syntax

fi

VERSION=$1

re="^[0-9]+$"
if ! [[ "${VERSION}" =~ ${re} ]]
then
	echo "! "
	echo "! $0: Version ${VERSION} is not a number!"
	echo "! "
	exit 1
fi


echo "# "
echo "# Tagging containers..."
echo "# "
docker tag splunk-lab dmuth1/splunk-lab
docker tag splunk-lab dmuth1/splunk-lab:${VERSION}
docker tag splunk-lab-ml dmuth1/splunk-lab-ml
docker tag splunk-lab-ml dmuth1/splunk-lab-ml:${VERSION}

echo "# "
echo "# Pushing containers to Docker Hub..."
echo "# "
docker push dmuth1/splunk-lab
docker push dmuth1/splunk-lab:${VERSION}
docker push dmuth1/splunk-lab-ml
docker push dmuth1/splunk-lab-ml:${VERSION}


echo "# Done!"

