#!/bin/bash
#
# Grab logs from a running instance of Splunk Lab
#

# Errors are fatal
set -e

echo "# "
echo "# Grabbing logs from Splunk Lab..."
echo "# "
echo "# Press ctrl-C to exit..."
echo "# "

docker logs -f splunk-lab

echo  "# Done!"

