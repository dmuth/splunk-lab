
<img src="img/splunk-logo.jpg" width="300" align="right" />

# Splunk Lab

This project lets you stand up a Splunk instance in Docker on a quick and dirty basis.


## Usage

Here are some ways in which to run this container--note that in all instances Splunk will
be listening on http://localhost:8000/, so change the first argument for `-p` if you want
a different port.  And whatever you do, do NOT expose this port to the Internet. (more on that later)

### Most Common Uses:

**If you are having a system issue, and want to ingest your logs, persist the ingested data between Splunk runs, and persist 
created dashboards as well:**

`docker run -p 8000:8000 -v /var/log:/logs -v $(pwd)/data:/data -v $(pwd)/app:/app -d dmuth1/splunk-lab`

**If you want to do data analytics on files in the logs/ directory, and persist the ingested data between Splunk runs, and
persist created dashboards as well:**

`docker run -p 8000:8000 -v $(pwd)/logs:/logs -v $(pwd)/data:/data -v $(pwd)/app:/app -d dmuth1/splunk-lab`


### Less Common Uses

Persist data between runs:

`docker run -p 8000:8000 -v $(pwd)/data:/data dmuth1/splunk-lab`

Persist data, and mount current directory as `/mnt`:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v $(pwd):/mnt dmuth1/splunk-lab`

Persist data, mount current directory as `/mnt`, and spawn interactive shell:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v $(pwd):/mnt -it dmuth1/splunk-lab bash`

Persist data and ingest mulitple directories:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v /var/log:/logs/syslog -v /opt/log:/logs/opt/ dmuth1/splunk-lab`

Persist data, mount local directory, save created dashboards and reports, and run in the background:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v $(pwd):/mnt -v $(pwd)/app:/app -d dmuth1/splunk-lab`


## A Word About Security

HTTPS is turned on by default.  Passwords such as `password` and `12345` are not permitted.

Please, <a href="https://diceware.dmuth.org/">use a strong password</a> if you are deploying
this on a public-facing machine.


## FAQ

### Does this work on Macs?

Sure does!  I built this on a Mac. :-)


## Development

Run the first line to stand up a development instance, and the subsequent 
lines when you want to push up changes to Docker Hub:

```
docker build . -t splunk-lab && docker run -p 8000:8000 -v $(pwd):/mnt -v /var/log:/logs -it splunk-lab bash
```

## Development with an Nginx instance feeding logs

If you'd like to spin up Splunk Lab, but also have a copy of Nginx running on <a href="http://localhost:9001">http://localhost:9001</a>, try running this command:

`docker-compose -f ./docker-compose-devel.yml`

Nginx's logs will be written to the same directory that Splunk Lab ingests logs from, so queries for
`index=main` should start to show results almost immediately.  Furthermore, a client is spun up 
which will run a GET request against Nginx once every 10 seconds, which will cause logs to be written
and ingested into the `main` Index almost immediately.


## Deployment

Run this when you're ready to push up changes to Docker Hub:

```
docker build . -t splunk-lab
docker tag splunk-lab dmuth1/splunk-lab && docker push dmuth1/splunk-lab
```


## Additional Reading

- <a href="https://github.com/dmuth/splunk-network-health-check">Splunk Network Health Check</a>


## Contact

My email is doug.muth@gmail.com.  I am also <a href="http://twitter.com/dmuth">@dmuth on Twitter</a> 
and <a href="http://facebook.com/dmuth">Facebook</a>!






