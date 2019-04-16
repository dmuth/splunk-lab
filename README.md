
<img src="img/splunk-logo.jpg" width="300" align="right" />

# Splunk Lab

This project lets you stand up a Splunk instance in Docker on a quick and dirty basis.
It is based on <a href="https://hub.docker.com/r/splunk/splunk/">Splunk's official Dockerfile</a>


## Quick Start!

Paste this in on the command line:

`bash <(curl -s https://raw.githubusercontent.com/dmuth/splunk-lab/master/go.sh)`

...and the script will print up what directory it will ingest logs from, etc.  Follow the on-screen
instructions for setting environment variables and you'll be up and running in no time!

## Screenshots

<a href="./img/splunk-rest-api-input.png"><img src="./img/splunk-rest-api-input.png" width="250" /></a> <a href="./img/splunk-syndication-feed.png"><img src="./img/splunk-syndication-feed.png" width="250" /></a> <a href="./img/splunk-cnn-headlines.png"><img src="./img/splunk-cnn-headlines.png" width="250" /></a>


## Splunk Apps Included

The following Splunk apps are included in this Docker image:

- <a href="https://splunkbase.splunk.com/app/2646/">Syndication Input</a>
- <a href="https://splunkbase.splunk.com/app/1546/">REST API Modular Input</a> (requires registration)
- Machine Learning
   - <a href="https://splunkbase.splunk.com/app/2882/">Python for Scientific Computing (for Linux 64-bit)</a>
   - <a href="https://splunkbase.splunk.com/app/2890/">Splunk Machine Learning Toolkit</a>

All apps are covered under their own license.  Please check <a href="vendor/README.md">the Apps page</a>
for more info.


## Free Sources of Data

I put together this curated list of free sources of data which can be pulled into Splunk
via one of the includes apps:

- Free
    - RSS
       - <a href="https://answers.splunk.com/feed/questions.rss">Recent questions posted to Splunk Answers</a>
       - <a href="http://www.cnn.com/services/rss/">CNN RSS feeds</a>
       - <a href="https://www.flickr.com/services/feeds/docs/photos_public/">Flickr's Public feed</a>
          - <a href="https://api.flickr.com/services/feeds/photos_public.gne">Public Photos</a>
          - <a href="https://api.flickr.com/services/feeds/photos_public.gne?tags=cheetah">Public photos tagged "cheetah"</a>
    - Non-RSS
       - Non-streaming
          - <a href="http://www3.septa.org/hackathon/">Philadelphia Public Transit API</a>
             - <a href="http://www3.septa.org/hackathon/TrainView/">Regional Rail Train Data</a>
          - <a href="https://developers.coinbase.com/docs/wallet/guides/price-data">Coinbase API</a>
         - <a href="https://www.weather.gov/documentation/services-web-api">National Weather Service</a>
            - <a href="https://api.weather.gov/gridpoints/PHI/49,75/forecast">Philadelphia Forecast</a>
            - <a href="https://api.weather.gov/gridpoints/PHI/49,75/forecast/hourly">Philadelphia Hourly Forecast</a>
         - <a href="https://www.alphavantage.co/">Alpha Vantage</a> - Free stock quotes
       - Streaming
          - <a href="https://www.meetup.com/meetup_api/docs/stream/2/rsvps/">Meetup RSVPs</a>
             - <a href="http://stream.meetup.com/2/rsvps">RSVP Endpoint</a>


## Common Uses

**If you are having a system issue, and want to ingest your logs, persist the ingested data between Splunk runs, and persist 
created dashboards as well:**

`docker run -p 8000:8000 -e SPLUNK_PASSWORD=password -v /var/log:/logs -v $(pwd)/data:/data -v $(pwd)/app:/app -d dmuth1/splunk-lab`

**If you want to do data analytics on files in the logs/ directory, and persist the ingested data between Splunk runs, and
persist created dashboards as well:**

`docker run -p 8000:8000 -e SPLUNK_PASSWORD=password -v $(pwd)/logs:/logs -v $(pwd)/data:/data -v $(pwd)/app:/app -d dmuth1/splunk-lab`


Once Splunk is running, you can log in with the `admin` user and password you specified, 
and doing a query for `index=main` should show your logs.

BTW, your password will be sanity checked.  Don't use `password` as your password. ;-)


## A Word About Security

HTTPS is turned on by default.  Passwords such as `password` and <a href="https://www.youtube.com/watch?v=a6iW-8xPw3k">12345</a> are not permitted.

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






