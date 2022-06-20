#!/bin/bash
#
# Wrapper script to set up Splunk Lab
#
# To test this script out, set up a webserver:
# 
#	python -m SimpleHTTPServer 8001
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
SPLUNK_EVENTGEN=${SPLUNK_EVENTGEN:-}
ETC_HOSTS=${ETC_HOSTS:-no}
REST_KEY=${REST_KEY:-}
RSS=${RSS:-}
DOCKER_NAME=${DOCKER_NAME:-splunk-lab}
DOCKER_RM=${DOCKER_RM:-1}
DOCKER_CMD=${DOCKER_CMD:-}
PRINT_DOCKER_CMD=${PRINT_DOCKER_CMD:-}
SSL_CERT=${SSL_CERT:-}
SSL_KEY=${SSL_KEY:-}


#
# Download all of our helper scripts.
#
function download_helper_scripts() {

	BASE_URL="https://raw.githubusercontent.com/dmuth/splunk-lab/master"
	#BASE_URL="http://localhost:8001"  # Debugging

	if test ! $(type -P curl)
	then
		echo "! "
		echo "! Curl needs to be installed on your system so that I can fetch helper scripts."
		echo "! "
		exit 1
	fi

	#
	# Create our bin directory and copy down some helper scripts
	#
	mkdir -p bin
	FILES=(
		attach.sh
		clean.sh
		create-1-million-events.py
		create-test-logfiles.sh
		kill.sh
		)

	for FILE in ${FILES[@]}
	do
		URL=${BASE_URL}/bin/${FILE}
		DEST=bin/${FILE}

		if test -f ${DEST}
		then
			continue
		fi

		echo -n "# Downloading ${URL} to ${DEST}..."
		curl -s --fail ${URL} > ${DEST} || true
		if test ! -s ${DEST}
		then
			echo
			echo "! Unable to find ${URL}"
			rm -f ${DEST}
			exit 1
		fi

		chmod 755 ${DEST}
		echo "...done!"

	done

} # End of download_helper_scripts()


#
# Go through all of our argument checking.
# And where I say arguments, I really mean environment variables, 
# because there are so many different options!
#
function check_args() {

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
	# Sanity check
	#
	if test "$ETC_HOSTS" != "no"
	then
		if test ! -f ${ETC_HOSTS}
		then
			echo "! Unable to read file '${ETC_HOSTS}' specfied in \$ETC_HOSTS!"
			exit 1
		fi
	fi


	#
	# Sanity check to make sure that both SSL_CERT *and* SSL_KEY are specified.
	#
	if test "${SSL_CERT}"
	then
		if test ! "${SSL_KEY}"
		then
			echo "! "
			echo "! \$SSL_CERT is specified but not \$SSL_KEY!"
			echo "! "
			exit 1
		fi

	elif test "${SSL_KEY}"
	then
		if test ! "${SSL_CERT}"
		then
			echo "! "
			echo "! \$SSL_KEY is specified but not \$SSL_CERT!"
			echo "! "
			exit 1
		fi

	fi

	#
	# Sanity check to make sure that SSL cert and key are both readable
	#
	if test "${SSL_CERT}"
	then
		if test ! -r "${SSL_CERT}"
		then
			echo "! "
			echo "! SSL Cert File ${SSL_CERT} does not exist or is not readable!"
			echo "! "
			exit 1
		fi

		if test ! -r "${SSL_KEY}"
		then
			echo "! "
			echo "! SSL Cert File ${SSL_KEY} does not exist or is not readable!"
			echo "! "
			exit 1
		fi

	fi

} # End of check_args()


#
# Create our Docker command from all of the arguments.
#
function create_docker_command() {

	#
	# Start forming our command
	#
	CMD="docker run \
		-p ${SPLUNK_PORT}:8000 \
		-e SPLUNK_PASSWORD=${SPLUNK_PASSWORD} "

	#
	# If SPLUNK_DATA is no, we're not exporting it. 
	# Useful for re-importing everything every time.
	#
	if test "${SPLUNK_DATA}" != "no"
	then
		CMD="$CMD -v $(pwd)/${SPLUNK_DATA}:/data "
	fi

	#echo "CMD: $CMD" # Debugging

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

	if test "${RSS}"
	then
		CMD="${CMD} -e RSS=${RSS}"
	fi

	if test "${ETC_HOSTS}" != "no"
	then
		CMD="$CMD -v $(pwd)/${ETC_HOSTS}:/etc/hosts.extra "
	fi

	if test "${SPLUNK_EVENTGEN}"
	then
		CMD="${CMD} -e SPLUNK_EVENTGEN=${SPLUNK_EVENTGEN}"
	fi

	#
	# If SSL files don't start with a leading slash, prefix with the full path
	#
	if test "${SSL_CERT}"
	then

		if test ${SSL_CERT:0:1} != "/"
		then
			SSL_CERT="$(pwd)/${SSL_CERT}"
		fi

		if test ${SSL_KEY:0:1} != "/"
		then
			SSL_KEY="$(pwd)/${SSL_KEY}"
		fi

		CMD="${CMD} -v ${SSL_CERT}:/ssl.cert -v ${SSL_KEY}:/ssl.key"

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

} # End of create_docker_command()


download_helper_scripts
check_args
create_docker_command


#
# If $PRINT_DOCKER_CMD is set, print out the Docker command that would be run then exit.
#
if test "${PRINT_DOCKER_CMD}"
then
	echo "$CMD"
	exit
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
if test "$REST_KEY"
then
	echo "# REST API Modular Input key:        ${REST_KEY}"
else
	echo "# REST API Modular Input key:        (Get yours at https://www.baboonbones.com/#activation and set with \$REST_KEY)"
fi

if test "$RSS"
then
	echo "# Synication of RSS feeds?:          YES"
else
	echo "# Synication of RSS feeds?:          NO (Enabled with \$RSS=yes)"
fi

if test "${SPLUNK_DATA}" != "no"
then
	echo "# Indexed data will be stored in:    ${SPLUNK_DATA} (Change with \$SPLUNK_DATA, disable with SPLUNK_DATA=no)"
else
	echo "# Indexed data WILL NOT persist.     (Change by setting \$SPLUNK_DATA)"
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

if test "$ETC_HOSTS" != "no"
then
	echo "# /etc/hosts addition:               ${ETC_HOSTS} (Disable with \$ETC_HOSTS=no)"
else
	echo "# /etc/hosts addition:               NO (Set with \$ETC_HOSTS=filename)"
fi

if test "$SPLUNK_EVENTGEN"
then
	echo "# Fake Webserver Event Generation:   YES (index=main sourcetype=nginx to view)"
else
	echo "# Fake Webserver Event Generation:   NO (Feel free to set with \$SPLUNK_EVENTGEN)"
fi

if test "${SSL_CERT}"
then
	echo "# SSL Cert and Key?                  YES (${SSL_CERT}, ${SSL_KEY})"	
else
	echo "# SSL Cert and Key?                  NO (Specify with \$SSL_CERT and \$SSL_KEY)"	
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



