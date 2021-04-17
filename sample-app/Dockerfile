
#
# Based on https://github.com/splunk/docker-splunk/blob/master/enterprise/Dockerfile
#
# I slimmed this down, as I have no desire to run as a separate user, set up a Deployment
# Server, generate PDFs, etc.  All I want to do is run a this single app.
#
FROM dmuth1/splunk-lab

#
# Change our default app to sample-app
#
RUN sed -i -e "s/splunk-lab/sample-app/" /opt/splunk/etc/users/admin/user-prefs/local/user-prefs.conf


