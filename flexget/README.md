# Flexget
This is a basic Flexget container used to watcha single RSS feed.  It uses the local-persist plugin to configure the volumes.

## Getting Started
The container can be accessed at the host ip on port 5050. Once the container is up and running you can modify the config through the UI by clicking on Config in the left hand nav.

The init.sh script will create a .env file to populate the DOWNLOAD variable.

## Prerequisits
**Environment Variables**
- DOWNLOAD is the directory where Flexget will download to
- LOCAL_PERSIST is the root of where data is persisted
- TZ is the timezone

**Local Persist Volume Plugin**

Install the [Local Persist](https://github.com/MatchbookLab/local-persist) volume plugin

```
curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | sudo bash
```

## Example Config
```
web_server: yes

schedules: 
  - tasks: torrents
    interval:
      minutes: 5

tasks:
  torrents:
    verify_ssl_certificates: no
    rss: 
      url: https://url.com/rss
    accept_all: yes
    download: /downloads
```

## Installing
Execute setup.sh which will bring the container up and create a link to the persist data.

**Alternatively**

```
docker-compose up --force-recreate --build -d
docker image prune -f
```

## Reference / Acknowledgments
- [docker-flexget](https://github.com/benni3005/docker-flexget)
- [Flexget RSS plugin](https://flexget.com/Plugins/rss)
- [Verify SSL Certs plugin](https://flexget.com/Plugins/verify_ssl_certificates)