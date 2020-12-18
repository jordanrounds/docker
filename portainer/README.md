# Portainer Container
This is a standard [Portainer](https://www.portainer.io/) container.  It uses the local-persist plugin to configure the volumes.

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

## Reference / Acknowledgements
- [Portainer](https://www.portainer.io/)
- [portainer-ce](https://hub.docker.com/r/portainer/portainer-ce)