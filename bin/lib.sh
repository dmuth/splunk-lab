#
# This file should be included to set important variables.
#

SPLUNK_PRODUCT="splunk"
SPLUNK_HOME="/opt/splunk"

#
# Version info
#
#SPLUNK_VERSION="9.2.0.1"
SPLUNK_VERSION="9.4.3"
SPLUNK_VERSION_MAJOR="9"

#wget -O splunk-9.4.3-237ebbd22314-linux-amd64.tgz "https://download.splunk.com/products/splunk/releases/9.4.3/linux/splunk-9.4.3-237ebbd22314-linux-amd64.tgz"

SPLUNK_VERSION_MINOR=${SPLUNK_VERSION}
#SPLUNK_BUILD="d8ae995bf219" # 9.2.0.1
SPLUNK_BUILD="237ebbd22314" # 9.4.3


#
# Download info
#
#SPLUNK_FILENAME="splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz"
SPLUNK_FILENAME="splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-linux-amd64.tgz"
SPLUNK_URL="https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}"

#
# Cache info
#
SPLUNK_CACHE_FILENAME="${CACHE}/${SPLUNK_FILENAME}"

