#!/bin/bash
#
# Attach to a running instance of Splunk Lab
#

# Errors are fatal
set -e

echo "# "
echo "# Attaching to the Splunk Lab container..."
echo "# "

docker exec -it splunk-lab bash

echo  "# Done!"

