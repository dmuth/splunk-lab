#!/bin/bash
#
# Remove a running instance of Splunk Lab
#

# Errors are fatal
set -e

echo "# "
echo "# Killing Splunk Lab..."
echo "# "

docker kill splunk-lab

echo  "# Done!"

