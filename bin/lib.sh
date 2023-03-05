#
# This file should be included to set important variables.
#

SPLUNK_PRODUCT="splunk"
SPLUNK_HOME="/opt/splunk"

#
# Version info
#
#SPLUNK_VERSION="8.2.6"
SPLUNK_VERSION="8.2.9"
SPLUNK_VERSION_MAJOR="8"
SPLUNK_VERSION_MINOR=${SPLUNK_VERSION}
#SPLUNK_BUILD="a6fe1ee8894b" # 8.2.6
SPLUNK_BUILD="4a20fb65aa78" # 8.2.9


#
# Download info
#
SPLUNK_FILENAME="splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz"
SPLUNK_URL="https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}"

#
# Cache info
#
SPLUNK_CACHE_FILENAME="${CACHE}/${SPLUNK_FILENAME}"

