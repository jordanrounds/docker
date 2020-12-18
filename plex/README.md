# Plex Docker Container
This is a standard Plex container.  It uses the local-persist plugin to configure the volumes.

## Getting Started
There's nothing super special here. The claim has been moved to a secret file and the path to the root where media should be read from is set by an environment variable.

## Prerequisits
**Environment Variables**
- MEDIA is the root of where media is to be mounted
- LOCAL_PERSIST is the root of where data is persisted
- TZ is the timezone

**Secrets**
- .secrets/plex.claim - the plex claim token

The claim token for the server to obtain a real server token. If not provided, server is will not be automatically logged in. If server is already logged in, this parameter is ignored. You can obtain a claim token to login your server to your plex account by visiting https://www.plex.tv/claim

**Local Persist Volume Plugin**

Install the [Local Persist](https://github.com/MatchbookLab/local-persist) volume plugin

```
curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | sudo bash
```

## Installing
Execute setup.sh which will bring the container up and create a link to the persist data.

**Alternatively**

```
docker-compose up --force-recreate --build -d
docker image prune -f
```

## Reference / Acknowledgments
- [Plex Docker Image](https://github.com/plexinc/pms-docker)