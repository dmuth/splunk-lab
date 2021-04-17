
<img src="../img/splunk-lab.png" width="250" align="right" />


# Sample App in Splunk Lab

This directory contains a sample app built in Splunk Lab.

It has customized build scripts and a Dockerfile which extends the official `splunk-lab` Docker image.

## Usage

- `./go.sh` will run this app in the background in Docker.
- It's not much different from `devel.sh`, except this app won't be mounted in `/mnt/


## Additional fake data types

This is a new fake data type with fake IP addresses and incrementing IDs, for testing purposes.
It can be viewed with this query: `index=main sourcetype=fake`

Make sure to launch Splunk with `SPLUNK_EVENTGEN=1` to get fake data.


### Adding in more fake data types

- Drop any samples in `sample-app/samples/`
- Then edit `sample-app/default/eventgen.conf` to add the new data sources
- Documentation on Eventgen can be found at http://splunk.github.io/eventgen/
- If you used `bin/devel.sh` to start your Docker container, you can type `/opt/splunk/bin/splunk restart` in the shell to restart the Splunk server and speed things up.


## Development

- `./bin/devel.sh` will run an instance of this app with a `bash` shell in the foreground
- Anything in `logs/` will be ingested into Splunk.
- Splunk Indexes will be written to `data/`
- This directory will be mounted in `/mnt/`
- The app directory `sample-app/` will be mounted in `/opt/splunk/etc/apps/sample-app/`
   - Any changes made in that directory will show up in the host machine's filesystem



