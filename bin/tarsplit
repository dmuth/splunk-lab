#!/bin/bash
#
# https://github.com/dmuth/tarsplit
#
# This script will take a tarball and split it into 2 or more parts.
# Most importantly, these parts WILL BE ALONG FILE BOUNDARIES.
# The reason for splitting along file foundaries is to that extraction
# can be done with plain old tar.
#
# The advantage of this approach is that things like larger Docker images can
# now be broken down into smaller layers, which each layer extracting a subset
# of the original tarball's directory structure.
#


# Errors are fatal
set -e

# Note our starting directory
DIR=$(pwd)

# Create a temp directory and a temp file
TMP=$(mktemp -d)
FILELIST=$(mktemp)

#
# Print our syntax and exit with an error.
#
function print_syntax() {
	echo "! "
	echo "! Syntax: $0 tarball num"
	echo "! "
	echo "! Split a tarball into a number of smaller parts, along file boundaries."
	echo "! "
	exit 1
}

if test ! "$2"
then
	print_syntax
fi

if test "$1" == "-h" -o "$1" == "--help"
then
	print_syntax
fi

FILE=$1
FILE_BASE=$(basename $FILE)
NUM_PARTS=$2

if test "${NUM_PARTS}" -lt 2
then
	echo "! "
	echo "! Nunber of parts must be at least 2! (You said: ${NUM_PARTS})"
	echo "! "
	exit 1
fi

#
# If our file doesn't start with a /, we'll need to prepend the starting directory.
#
TAR=${FILE}
if test ${TAR:0:1} != "/"
then
	TAR=${DIR}/${TAR}
fi

if test ! -f "${TAR}"
then
	echo "! "
	echo "! File not found: ${TAR}"
	echo "! "
	exit 1
fi

#
# Change to our temp directory for all work
#
pushd ${TMP} > /dev/null
#echo "Temp directory: ${TMP}" # Debugging

NUM_FILES=$(tar tfvz ${TAR} | wc -l | awk '{print $1}' )
echo "# Number of files in ${FILE}: $NUM_FILES"
echo "# Number of parts requested: ${NUM_PARTS}"
NUM_FILES_PER_PART=$(( ${NUM_FILES} / ${NUM_PARTS} ))
echo "# Number of files per part: ${NUM_FILES_PER_PART} (last part rounds up)"

echo "# Extracting file '${FILE}' so that we can then build parts from that directory.."
tar xfz ${TAR}

START=""
END=""
for PART in $(seq -w $NUM_PARTS)
do
	echo "# Generating part ${PART}/${NUM_PARTS}..."

	if test ! "${START}"
	then
		START=1
		END=${NUM_FILES_PER_PART}
	else
		START=$(( ${START} + ${NUM_FILES_PER_PART} ))
		END=$(( ${START} + ${NUM_FILES_PER_PART} - 1 ))
	fi

	if test "${PART}" == "${NUM_PARTS}"
	then
		echo "# We're on the last part, so file Index is set to \$ for sed..."
		END="$"
	fi

	echo "# Starting file index: ${START}, ending file index: ${END}"

	#echo "tar tfz ${TAR} | sed -n ${START},${END}p > ${FILELIST}" # Degbugging
	tar tfz ${TAR} | sed -n ${START},${END}p > ${FILELIST}
	#cat ${FILELIST} # Debugging

	PART_FILE="${FILE}-part-${PART}-of-${NUM_PARTS}"
	PART_FILE="${DIR}/${FILE_BASE}-part-${PART}-of-${NUM_PARTS}"

	echo "# Building part '${PART_FILE}'..."

	#echo tar cfz ${PART_FILE} --files-from ${FILELIST} --no-recursion # Debugging
	tar cfz ${PART_FILE} --files-from ${FILELIST} --no-recursion

done

# Cleanup
rm -rf ${TMP} ${FILELIST}


