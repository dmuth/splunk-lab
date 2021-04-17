
<img src="../img/splunk-lab.png" width="250" align="right" />


# Sample App in Splunk Lab

This directory contains a sample app built in Splunk Lab.

It has customized build scripts and a Dockerfile which extends the official `splunk-lab` Docker image.


## Development

- `./bin/devel.sh` will run an instance of this app with a `bash` shell in the foreground
- Anything in `logs/` will be ingested into Splunk.
- Splunk Indexes will be written to `data/`
- This directory will be mounted in `/mnt/`
- The app directory `sample-app/` will be mounted in `/opt/splunk/etc/apps/sample-app/`
   - Any changes made in that directory will show up in the host machine's filesystem

## Usage

- `./go.sh` will run this app in the background in Docker.
- It's not much different from `devel.sh`, except this app won't be mounted in `/mnt/



