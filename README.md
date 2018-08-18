
# Splunk Lab

This project lets you stand up a Splunk instance in Docker on a quick and dirty basis.


## Usage

Here are some ways in which to run this container--note that in all instances Splunk will
be listening on http://localhost:8000/, so change the first argument for `-p` if you want
a different port.  And whatever you do, do NOT expose this port to the Internet. (more on that later)


Persist data between runs:

`docker run -p 8000:8000 -v $(pwd)/data:/data dmuth1/splunk-lab`

Persist data, and mount current directory as `/mnt`:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v $(pwd):/mnt dmuth1/splunk-lab`

Persist data, mount current directory as `/mnt`, and spawn interactive shell:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v $(pwd):/mnt -it dmuth1/splunk-lab bash`

Persist data and ingest `/var/log/`:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v /var/log:/logs dmuth1/splunk-lab`

Persist data, ingest `/var/log/`, and run in the background:

`docker run -p 8000:8000 -v $(pwd)/data:/data -v $(pwd):/mnt -d dmuth1/splunk-lab`


## A Word About Security

This Splunk instance has a default login/password of `admin/password`.  It should not be exposed
to the Internet under ANY circumstances.  If you are running this container on a production machine
for diagnostic purposes, port 8000 should be firewalled off from the outside world.  Here's to do 
that in iptables:

```
iptables -I INPUT -p tcp --dport 8000 -j DROP -m comment --comment "Splunk: Drop"
iptables -I INPUT -p tcp -d localhost --dport 8000 -j ACCEPT -m comment --comment "Splunk: Accept"
ip6tables -I INPUT -p tcp --dport 8000 -j DROP -m comment --comment "Splunk: Drop"
ip6tables -I INPUT -p tcp -d localhost --dport 8000 -j ACCEPT -m comment --comment "Splunk: Accept"
```

The above will do the following:

- Insert a rule at the start of the `INPUT` chain to drop all traffic to port 8000
- Insert a rule at the start of the same chain (before the previous rule) to allow traffic to port 8000 from `localhost` ONLY.
- Then do the same for IPv6.  You do have iptables rules for IPv6, right? :-)


To access port 8000 from another host, you'd SSH to the target host as follows:
`ssh -L 8000:localhost:8000 HOSTNAME`.

If you are already SSHed in, you can set up forwardings on the fly, try this instead:
- Press the `<return>` key.
- Type `~C`.  That will bring up an `ssh> ` prompt.
- Type `-L 8000:localhost:8000` and hit `<return>`.  That will set up the port forwarding on the fly.
- Go to http://localhost:8000/

## FAQ

### Does this work on Macs?

Sure does!  I built this on a Mac. :-)



## Development

Run the first line to stand up a development instance, and the subsequent 
lines when you want to push up changes to Docker Hub:

```
docker build . -t splunk-lab && docker run -p 8000:8000 -v $(pwd):/mnt -v /var/log:/logs -it splunk-lab bash
docker tag splunk-lab dmuth1/splunk-lab
docker push dmuth1/splunk-lab
```

