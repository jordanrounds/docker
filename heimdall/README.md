# Heimdall
This is a standard [Heimdall](https://heimdall.site/) container.  It uses the local-persist plugin to configure the volumes.

## Getting Started
By default the container is setup to be accessed on ports 1080 and 1043 instead of 80 and 443 so that it can be run alongside NGINX. This isnt necessary if you have something else running on 80 and 443.0

## Prerequisits
**Environment Variables**
- LOCAL_PERSIST is the root of where data is persisted
- TZ is the timezone

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
- [Heimdall](https://heimdall.site/)
- [Heimdall Docker Image](https://github.com/linuxserver/Heimdall)