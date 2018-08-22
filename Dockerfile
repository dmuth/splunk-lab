
#
# Based on https://github.com/splunk/docker-splunk/blob/master/enterprise/Dockerfile
#
# I slimmed this down, as I have no desire to run as a separate user, set up a Deployment
# Server, generate PDFs, etc.  All I want to do is run a this single app.
#
FROM debian:stretch

ENV SPLUNK_PRODUCT splunk
ENV SPLUNK_VERSION 7.1.2
ENV SPLUNK_BUILD a0c72a66db66
ENV SPLUNK_FILENAME splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz

ENV SPLUNK_HOME /opt/splunk

ARG DEBIAN_FRONTEND=noninteractive

# make the "en_US.UTF-8" locale so splunk will be utf-8 enabled by default
RUN apt-get update  && apt-get install -y --no-install-recommends apt-utils && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Download official Splunk release, verify checksum and unzip in /opt/splunk
# Also backup etc folder, so it will be later copied to the linked volume
RUN apt-get update && apt-get install -y wget procps fping less iptables \
    && mkdir -p ${SPLUNK_HOME} \
    && wget -qO /tmp/${SPLUNK_FILENAME} https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME} \
    && wget -qO /tmp/${SPLUNK_FILENAME}.md5 https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}.md5 \
    && (cd /tmp && md5sum -c ${SPLUNK_FILENAME}.md5) \
    && tar xzf /tmp/${SPLUNK_FILENAME} --strip 1 -C ${SPLUNK_HOME} \
    && rm /tmp/${SPLUNK_FILENAME} \
    && rm /tmp/${SPLUNK_FILENAME}.md5 \
    && apt-get purge -y --auto-remove wget 

#
# Copy in some Splunk configuration
#
COPY splunk-config/inputs.conf /opt/splunk/etc/system/local/inputs.conf
COPY splunk-config/server.conf /opt/splunk/etc/system/local/server.conf
COPY splunk-config/splunk-launch.conf /opt/splunk/etc/
COPY splunk-config/user-seed.conf /opt/splunk/etc/system/local/user-seed.conf.in
COPY splunk-config/ui-prefs.conf /opt/splunk/etc/system/local/ui-prefs.conf
COPY splunk-config/user-prefs.conf /opt/splunk/etc/apps/user-prefs/local/user-prefs.conf
COPY splunk-config/web.conf /opt/splunk/etc/system/local/web.conf.in


#
# Link to our data directory so that any data we create gets exported.
#
RUN ln -s /opt/splunk/var/lib/splunk/ /data


#
# Link to our search app so that anything we create get exported.
#
RUN ln -s /opt/splunk/etc/apps/search/local /app

#
# Expose Splunk web
#
EXPOSE 8000/tcp

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]



