#!/bin/bash
#
# Script to run from Splunk
#


TZ="${TZ:=EST5EDT}"
SPLUNK_PASSWORD="${SPLUNK_PASSWORD:=password}"

#
# Set our default password
#
pushd /opt/splunk/etc/system/local/ >/dev/null

cat user-seed.conf.in | sed -e "s/%password%/${SPLUNK_PASSWORD}/" > user-seed.conf
cat web.conf.in | sed -e "s/%password%/${SPLUNK_PASSWORD}/" > web.conf

popd > /dev/null

#
# Start Splunk
#
/opt/splunk/bin/splunk start --accept-license

echo "# "
echo "# "
echo "# Available env vars: TZ, SPLUNK_PASSWORD"
echo "# "
echo "# "
echo "# Here are some ways in which to run this container: "
echo "# "
echo "# Persist data between runs:"
echo "# 	docker run -p 8000:8000 -v \$(pwd)/data:/data dmuth1/splunk-lab "
echo "# "
echo "# Persis data, and mount current directory as /mnt:"
echo "# 	docker run -p 8000:8000 -v \$(pwd)/data:/data -v \$(pwd):/mnt dmuth1/splunk-lab "
echo "# "
echo "# Persist data, mount current directory as /mnt, and spawn an interactive shell: "
echo "# 	docker run -p 8000:8000 -v \$(pwd)/data:/data -v \$(pwd):/mnt -it dmuth1/splunk-lab bash "
echo "# "
echo "# Persist data and ingest /var/log/:"
echo "# 	docker run -p 8000:8000 -v \$(pwd)/data:/data -v /var/log:/logs dmuth1/splunk-lab "
echo "# "
echo "# Persist data, ingest /var/log/, and run in the background:"
echo "# 	docker run -p 8000:8000 -v \$(pwd)/data:/data -v \$(pwd):/mnt -d dmuth1/splunk-lab "
echo "# "
echo "# "


if test "$1"
then
	echo "# "
	echo "# Arguments detected! "
	echo "# "
	echo "# Executing: $@"
	echo "# "

	exec "$@"

fi


#
# Tail this file so that Splunk keeps running
#
tail -f /opt/splunk/var/log/splunk/splunkd_stderr.log



