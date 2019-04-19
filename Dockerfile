
#
# Based on https://github.com/splunk/docker-splunk/blob/master/enterprise/Dockerfile
#
# I slimmed this down, as I have no desire to run as a separate user, set up a Deployment
# Server, generate PDFs, etc.  All I want to do is run a this single app.
#
FROM splunk-lab-core


#
# Copy in vendor/README.md, which contains license info on the various apps.
#
COPY vendor/README.md /README.md


#
# Copy in some Splunk configuration
#
COPY splunk-config/inputs.conf /opt/splunk/etc/system/local/inputs.conf
COPY splunk-config/props.conf /opt/splunk/etc/system/local/props.conf
COPY splunk-config/server.conf /opt/splunk/etc/system/local/server.conf
COPY splunk-config/splunk-launch.conf /opt/splunk/etc/
COPY splunk-config/user-seed.conf /opt/splunk/etc/system/local/user-seed.conf.in
COPY splunk-config/ui-prefs.conf /opt/splunk/etc/system/local/ui-prefs.conf
COPY splunk-config/user-prefs.conf /opt/splunk/etc/apps/user-prefs/local/user-prefs.conf
COPY splunk-config/web.conf /opt/splunk/etc/system/local/web.conf.in


#
# Install the Splunk Lab app and set it to the default
#
WORKDIR /tmp
COPY splunk-lab-app /opt/splunk/etc/apps/splunk-lab
RUN mkdir -p /opt/splunk/etc/users/admin/user-prefs/local
RUN mv /opt/splunk/etc/apps/splunk-lab/user-prefs.conf /opt/splunk/etc/users/admin/user-prefs/local/


#
# Expose Splunk web
#
EXPOSE 8000/tcp

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]



