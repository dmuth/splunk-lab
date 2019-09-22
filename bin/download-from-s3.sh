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

mkdir -p splunk-packages-from-s3
pushd splunk-packages-from-s3 >/dev/null

echo "# "
echo "# Downloading packages from S3..."
echo "# "

FILES="halo-custom-visualization_113.tgz
	nlp-text-analytics_102.tgz
	python-for-scientific-computing-for-linux-64-bit_14.tgz
	rest-api-modular-input_154.tgz
	sankey-diagram-custom-visualization_130.tgz
	slack-notification-alert_203.tgz
	splunk-machine-learning-toolkit_420.tgz
	syndication-input-rssatomrdf_12.tgz
	wordcloud-custom-visualization_111.tgz
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
		--bucket dmuth-splunk-lab \
		--key ${FILE} \
		--request-payer requestor \
		${TMP}
	mv $TMP $FILE

done

echo "# Done downloading packages!"

