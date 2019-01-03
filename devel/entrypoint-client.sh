#!/bin/sh
#
# Run queries against the Nginx server in an endless loop.
#

# Errors are fatal
set -e

while true
do

	GET=`date +%Y%m%d-%H%M%S`
	curl -s http://nginx/?${GET} > /dev/null || true

	sleep 10

done


