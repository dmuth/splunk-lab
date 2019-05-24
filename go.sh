#!/bin/bash
#
# Wrapper script to set up Splunk Lab
#
# To test this script out, set up a webserver:
# 
#	python -m SimpleHTTPServer 8000
#
# Then run the script:
#
#	bash <(curl -s localhost:8000/go.sh)
#


# Errors are fatal
set -e


#
# Set default values for our vars
#
SPLUNK_PASSWORD=${SPLUNK_PASSWORD:-password1}
SPLUNK_DATA=${SPLUNK_DATA:-data}
SPLUNK_LOGS=${SPLUNK_LOGS:-logs}
SPLUNK_PORT=${SPLUNK_PORT:-8000}
SPLUNK_APP="app"
SPLUNK_ML=${SPLUNK_ML:--1}
SPLUNK_DEVEL=${SPLUNK_DEVEL:-}
REST_KEY=${REST_KEY:-}
DOCKER_NAME=${DOCKER_NAME:-splunk-lab}
DOCKER_RM=${DOCKER_RM:-1}
DOCKER_CMD=${DOCKER_CMD:-}


if test "$SPLUNK_START_ARGS" != "--accept-license"
then
	echo "! "
	echo "! You need to accept the Splunk License in order to continue."
	echo "! Please restart this container with SPLUNK_START_ARGS set to \"--accept-license\" "
	echo "! as follows: "
	echo "! "
	echo "! SPLUNK_START_ARGS=--accept-license"
	echo "! "
	exit 1
fi


#
# Yes, I am aware that the password checking logic is a duplicate of what's in the 
# container's entry point script.  But if someone is running Splunk Lab through this
# script, I want bad passwords to cause failure as soon as possible, because it's 
# easier to troubleshoot here than through Docker logs.
#
if test "$SPLUNK_PASSWORD" == "password"
then
	echo "! "
	echo "! "
	echo "! Cowardly refusing to set the password to 'password'. Please set a different password."
	echo "! "
	echo "! If you need help picking a secure password, there's an app for that:"
	echo "! "
	echo "!	https://diceware.dmuth.org/"
	echo "! "
	echo "! "
	exit 1
fi

PASSWORD_LEN=${#SPLUNK_PASSWORD}
if test $PASSWORD_LEN -lt 8
then
	echo "! "
	echo "! "
	echo "! Admin password needs to be at least 8 characters!"
	echo "! "
	echo "! Password specified: ${SPLUNK_PASSWORD}"
	echo "! "
	echo "! "
	exit 1
fi


#
# Massage -1 into an empty string.  This is for the benefit of if we're
# called from devel.sh.
#
if test "$SPLUNK_ML" == "-1"
then
	SPLUNK_ML=""
fi


if ! test $(which docker)
then
	echo "! "
	echo "! Docker not found in the system path!"
	echo "! "
	echo "! Please double-check that Docker is installed on your system, otherwise you "
	echo "! can go to https://www.docker.com/ to download Docker. "
	echo "! "
	exit 1
fi


#
# Sanity check to make sure our log directory exists
#
if test ! -d "${SPLUNK_LOGS}"
then
	echo "! "
	echo "! ERROR: Log directory '${SPLUNK_LOGS}' does not exist!"
	echo "! "
	echo "! Please set the environment variable \$SPLUNK_LOGS to the "
	echo "! directory you wish to ingest and re-run this script."
	echo "! "
	exit 1
fi


#
# Start forming our command
#
CMD="docker run \
	-p ${SPLUNK_PORT}:8000 \
	-e SPLUNK_PASSWORD=${SPLUNK_PASSWORD} \
	-v $(pwd)/${SPLUNK_DATA}:/data "


#
# If the logs value doesn't start with a leading slash, prefix it with the full path
#
if test ${SPLUNK_LOGS:0:1} != "/"
then
	SPLUNK_LOGS="$(pwd)/${SPLUNK_LOGS}"
fi

CMD="${CMD} -v ${SPLUNK_LOGS}:/logs"

if test "${REST_KEY}"
then
	CMD="${CMD} -e REST_KEY=${REST_KEY}"
fi

#
# Again, doing the same unusual stuff that we are with DOCKER_RM,
# since the default is to hvae a name.
#
if test "${DOCKER_NAME}" == "no"
then
	DOCKER_NAME=""
fi

if test "${DOCKER_NAME}"
then
	CMD="${CMD} --name ${DOCKER_NAME}"
fi

#
# Only disable --rm if DOCKER_RM is set to "no".
# We want --rm action by default, since we also have a default name
# and don't want name conflicts.
#
if test "$DOCKER_RM" == "no"
then
	DOCKER_RM=""
fi

if test "${DOCKER_RM}"
then
	CMD="${CMD} --rm"
fi

if test "$SPLUNK_START_ARGS" -a "$SPLUNK_START_ARGS" != 0
then
	CMD="${CMD} -e SPLUNK_START_ARGS=${SPLUNK_START_ARGS}"
fi


#
# Only run in the foreground if devel mode is set.
# Otherwise, giving users the option to run in foreground will only 
# confuse those that are new to Docker.
#
if test ! "$SPLUNK_DEVEL"
then
	CMD="${CMD} -d "
	CMD="${CMD} -v $(pwd)/${SPLUNK_APP}:/opt/splunk/etc/apps/splunk-lab/local "

else 
	CMD="${CMD} -it"
	#
	# Utility mount :-)
	#
	CMD="${CMD} -v $(pwd):/mnt "
	#
	# In devel mode, we'll mount the splunk-lab/ directory to the app directory
	# here, and the entrypoint.sh script will create the local/ symlink
	# (with build.sh removing said symlink before building any images)
	#
	CMD="${CMD} -v $(pwd)/splunk-lab-app:/opt/splunk/etc/apps/splunk-lab "
	CMD="${CMD} -e SPLUNK_DEVEL=${SPLUNK_DEVEL} "

fi


if test "$DOCKER_CMD"
then
	CMD="${CMD} ${DOCKER_CMD} "
fi


IMAGE="dmuth1/splunk-lab"
#IMAGE="splunk-lab" # Debugging/testing
if test "$SPLUNK_ML"
then
	IMAGE="dmuth1/splunk-lab-ml"
	#IMAGE="splunk-lab-ml" # Debugging/testing
fi

CMD="${CMD} ${IMAGE}"

if test "$SPLUNK_DEVEL"
then
	CMD="${CMD} bash"
fi

echo
echo "    ____            _                   _        _               _     "
echo "   / ___|   _ __   | |  _   _   _ __   | | __   | |       __ _  | |__  "
echo "   \___ \  | '_ \  | | | | | | | '_ \  | |/ /   | |      / _\` | | '_ \ "
echo "    ___) | | |_) | | | | |_| | | | | | |   <    | |___  | (_| | | |_) |"
echo "   |____/  | .__/  |_|  \__,_| |_| |_| |_|\_\   |_____|  \__,_| |_.__/ "
echo "           |_|                                                         "
echo

echo "# "
if test ! "${SPLUNK_DEVEL}"
then
	echo "# About to run Splunk Lab!"
else
	echo "# About to run Splunk Lab IN DEVELOPMENT MODE!"
fi
echo "# "
echo "# Before we do, please take a few seconds to ensure that your options are correct:"
echo "# "
echo "# URL:                               https://localhost:${SPLUNK_PORT} (Change with \$SPLUNK_PORT)"
echo "# Login/password:                    admin/${SPLUNK_PASSWORD} (Change with \$SPLUNK_PASSWORD)"
echo "# "
echo "# Logs will be read from:            ${SPLUNK_LOGS} (Change with \$SPLUNK_LOGS)"
echo "# App dashboards will be stored in:  ${SPLUNK_APP} (Change with \$SPLUNK_APP)"
echo "# Indexed data will be stored in:    ${SPLUNK_DATA} (Change with \$SPLUNK_DATA)"
if test "$REST_KEY"
then
	echo "# Rest API Modular Input key:        ${REST_KEY}"
else
	echo "# Rest API Modular Input key:        (Get yours at https://www.baboonbones.com/#activation and set with \$REST_KEY)"
fi
if test "$DOCKER_NAME"
then
	echo "# Docker container name:             ${DOCKER_NAME} (Disable automatic name with \$DOCKER_NAME=no)"
else
	echo "# Docker container name:             (Set with \$DOCKER_NAME, if you like)"
fi

if test "$DOCKER_RM"
then
	echo "# Removing container at exit?        YES (Disable with \$DOCKER_RM=no)"
else
	echo "# Removing container at exit?        NO (Set with \$DOCKER_RM=1)"
fi

if test "$DOCKER_CMD"
then
	echo "# Docker command injection:          ${DOCKER_CMD}"
else
	echo "# Docker command injection:          (Feel free to set with \$DOCKER_CMD)"
fi

echo "# "
if test "$SPLUNK_ML"
then
	echo "# Splunk Machine Learning Image?     YES"
else
	echo "# Splunk Machine Learning Image?     NO (Enable by setting \$SPLUNK_ML in the environment)"
fi

echo "# "

if test "$SPLUNK_PASSWORD" == "password1"
then
	echo "# "
	echo "# PLEASE NOTE THAT YOU USED THE DEFAULT PASSWORD"
	echo "# "
	echo "# If you are testing this on localhost, you are probably fine."
	echo "# If you are not, then PLEASE use a different password for safety."
	echo "# If you have trouble coming up with a password, I have a utility "
	echo "# at https://diceware.dmuth.org/ which will help you pick a password "
	echo "# that can be remembered."
	echo "# "
fi

echo "> "
echo "> Press ENTER to run Splunk Lab with the above settings, or ctrl-C to abort..."
echo "> "
read


echo "# "
echo "# Launching container..."
echo "# "

if test "$SPLUNK_DEVEL"
then
	$CMD

elif test ! "$DOCKER_NAME"
then
	ID=$($CMD)
	SHORT_ID=$(echo $ID | cut -c-4)

else
	ID=$($CMD)
	SHORT_ID=$DOCKER_NAME

fi

if test ! "$SPLUNK_DEVEL"
then
	echo "#"
	echo "# Running Docker container with ID: ${ID}"
	echo "#"
	echo "# Inspect container logs with: docker logs ${SHORT_ID}"
	echo "#"
	echo "# Kill container with: docker kill ${SHORT_ID}"
	echo "#"

else
	echo "# All done!"

fi



