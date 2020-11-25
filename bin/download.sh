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
SPLUNK_VERSION="8.1.0.1"
SPLUNK_BUILD="24fd52428b5a"
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
fi

echo "# "
echo "# Splitting up the Splunk tarball into 10 separate pieces..."
echo "# "
if test ! -f "splunk-8.1.0.1-24fd52428b5a-Linux-x86_64.tgz-part-10-of-10"
then
	../bin/tarsplit ${SPLUNK_FILENAME} 10
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

echo "# Done downloading packages!"

