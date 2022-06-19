#!/bin/bash
#
# This script downloads our Splunk packages from the Splunk Lab S3 
# bucket that I created.  That bucket is set to "Requestor Pays",
# so that people building their own copies don't drive up my AWS bill. :-)
#


# Errors are fatal
set -e

# Change to our parent directory
pushd $(dirname $0)/.. > /dev/null

BUCKET="dmuth-splunk-lab"
CACHE="cache"

SPLUNK_PRODUCT="splunk"
SPLUNK_VERSION="8.2.6"
SPLUNK_BUILD="a6fe1ee8894b"
SPLUNK_FILENAME="splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz"
SPLUNK_URL="https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}"
SPLUNK_CACHE_FILENAME="${CACHE}/${SPLUNK_FILENAME}"

mkdir -p ${CACHE}
pushd ${CACHE} >/dev/null > /dev/null

echo "# "
echo "# Downloading Splunk..."
echo "# "
if test ! -f "${SPLUNK_FILENAME}"
then
	wget -O ${SPLUNK_FILENAME}.tmp ${SPLUNK_URL}
	mv ${SPLUNK_FILENAME}.tmp ${SPLUNK_FILENAME}

else
	echo "# Oh, ${SPLUNK_FILENAME} already exists, skipping!"

fi

NUM_PARTS=10
if test ! -f "splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz-part-${NUM_PARTS}-of-${NUM_PARTS}"
then
	echo "# "
	echo "# Splitting up the Splunk tarball into ${NUM_PARTS} separate pieces..."
	echo "# "
	../bin/tarsplit ${SPLUNK_FILENAME} ${NUM_PARTS}

else
	echo "# Oh, splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz-part-${NUM_PARTS}-of-${NUM_PARTS} already exists, skipping!"

fi

echo "# "
echo "# Downloading packages from S3..."
echo "# "

FILES="halo-custom-visualization_113.tgz
	nlp-text-analytics_102.tgz
	python-for-scientific-computing-for-linux-64-bit_202.tgz
	rest-api-modular-input_198.tgz
	sankey-diagram-custom-visualization_130.tgz
	slack-notification-alert_203.tgz
	splunk-machine-learning-toolkit_520.tgz 
        syndication-input-rssatomrdf_124.tgz
	wordcloud-custom-visualization_111.tgz
	splunk-dashboard-examples_800.tgz
        eventgen_720.tgz
	"

for FILE in $FILES
do
	if test -f $FILE
	then
		echo "# File '${FILE}' exists, skipping!"
		continue
	fi

	echo "# Downloading file '${FILE}'..."

	TMP=$(mktemp -t splunk-lab)
	aws s3api get-object \
		--bucket ${BUCKET} \
		--key ${FILE} \
		--request-payer requester \
		${TMP}
	mv $TMP $FILE

done

NUM_PARTS=8
if test ! -f "python-for-scientific-computing-for-linux-64-bit_202.tgz-part-${NUM_PARTS}-of-${NUM_PARTS}"
then
	echo "# "
	echo "# Splitting up Python package into ${NUM_PARTS} separate pieces..."
	echo "# "
	../bin/tarsplit "python-for-scientific-computing-for-linux-64-bit_202.tgz" ${NUM_PARTS}
fi


echo "# Done downloading packages!"

