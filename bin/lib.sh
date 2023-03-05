#
# This file should be included to set important variables.
#

SPLUNK_PRODUCT="splunk"

#
# Version info
#
SPLUNK_VERSION="8.2.6"
SPLUNK_VERSION_MAJOR="8"
SPLUNK_VERSION_MINOR=${SPLUNK_VERSION}

#
# Download info
#
SPLUNK_BUILD="a6fe1ee8894b"
SPLUNK_FILENAME="splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz"
SPLUNK_URL="https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}"

#
# Cache info
#
SPLUNK_CACHE_FILENAME="${CACHE}/${SPLUNK_FILENAME}"

