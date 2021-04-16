#!/bin/bash

# Errors are fatal
set -e

#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

SPLUNK_DEVEL=1 REST_KEY=${REST_KEY} SPLUNK_PASSWORD=${SPLUNK_PASSWORD:-password1} ./go.sh


