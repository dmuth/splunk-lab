
<img src="img/splunk-logo.jpg" width="300" align="right" />

# Splunk Lab

This project lets you stand up a Splunk instance in Docker on a quick and dirty basis.
It is based on <a href="https://hub.docker.com/r/splunk/splunk/">Splunk's official Dockerfile</a>


## Quick Start!

Paste this in on the command line:

`bash <(curl -s https://raw.githubusercontent.com/dmuth/splunk-lab/master/go.sh)`

...and the script will print up what directory it will ingest logs from, etc.  Follow the on-screen
instructions for setting environment variables and you'll be up and running in no time!


## Usage

Here are some ways in which to run this container--note that in all instances Splunk will
be listening on <a href="https://localhost:8000/">https://localhost:8000/</a>, so change the first argument for `-p` if you want
a different port.


### Most Common Uses:

**If you are having a system issue, and want to ingest your logs, persist the ingested data between Splunk runs, and persist 
created dashboards as well:**

`docker run -p 8000:8000 -e SPLUNK_PASSWORD=password -v /var/log:/logs -v $(pwd)/data:/data -v $(pwd)/app:/app -d dmuth1/splunk-lab`

**If you want to do data analytics on files in the logs/ directory, and persist the ingested data between Splunk runs, and
persist created dashboards as well:**

`docker run -p 8000:8000 -e SPLUNK_PASSWORD=password -v $(pwd)/logs:/logs -v $(pwd)/data:/data -v $(pwd)/app:/app -d dmuth1/splunk-lab`


Once Splunk is running, you can log in with the `admin` user and password you specified, 
and doing a query for `index=main` should show your logs.

BTW, your password will be sanity checked.  Don't use `password` as your password. ;-)


### Less Common Uses

Persist data between runs:

`docker run -p 8000:8000 -v $(pwd)/data:/data dmuth1/splunk-lab`

Persist data, mount current directory as `/mnt`, and spawn interactive shell:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v $(pwd):/mnt -it dmuth1/splunk-lab bash`

Persist data and ingest mulitple directories:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v /var/log:/logs/syslog -v /opt/log:/logs/opt/ dmuth1/splunk-lab`



## A Word About Security

HTTPS is turned on by default.  Passwords such as `password` and `12345` are not permitted.

Please, <a href="https://diceware.dmuth.org/">use a strong password</a> if you are deploying
this on a public-facing machine.


## FAQ

### Does this work on Macs?

Sure does!  I built this on a Mac. :-)


## Development

I wrote a series of helper scripts in `bin/` to make the process easier:

- `./bin/build.sh` - Build the container.
- `./bin/push.sh` - Tag and push the container.
- `./bin/devel.sh` - Build and tag the container, then start it with an interactive bash shell.
   - This is a wrapper for the above-mentioned `go.sh` script. Any environment variables that work there will work here.
- `./bin/clean.sh` - Remove logs/ and/or data/ directories.


## Development with an Nginx instance feeding logs

If you'd like to spin up Splunk Lab, but also have a copy of Nginx running on <a href="http://localhost:9001">http://localhost:9001</a>, try running this command:

`docker-compose -f ./devel/docker-compose.yml up`

Nginx's logs will be written to the same directory that Splunk Lab ingests logs from, so queries for
`index=main` should start to show results almost immediately.  Furthermore, a client is spun up 
which will run a GET request against Nginx once every 10 seconds, which will cause logs to be written
and ingested into the `main` Index almost immediately.


## Additional Reading

- <a href="https://github.com/dmuth/splunk-network-health-check">Splunk Network Health Check</a>


## Contact

My email is doug.muth@gmail.com.  I am also <a href="http://twitter.com/dmuth">@dmuth on Twitter</a> 
and <a href="http://facebook.com/dmuth">Facebook</a>!






