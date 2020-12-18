# Node Red Docker Container
This project is a default Node Red container with some additional preinstalled nodes focussed around Home Assistant, Hue, dashboards, and automations and timing.  It uses the local-persist plugin to configure the volumes.

## Getting Started
This is the list of pre-installed nodes:

- [node-red-contrib-home-assistant-websocket](https://flows.nodered.org/node/node-red-contrib-home-assistant-websocket)
- [node-red-contrib-stoptimer](https://flows.nodered.org/node/node-red-contrib-stoptimer)
- [node-red-contrib-actionflows](https://flows.nodered.org/node/node-red-contrib-actionflows)
- [node-red-contrib-time-range-switch](https://flows.nodered.org/node/node-red-contrib-time-range-switch)
- [node-red-contrib-timecheck](https://flows.nodered.org/node/node-red-contrib-timecheck)
- [node-red-contrib-bigtimer](https://flows.nodered.org/node/node-red-contrib-bigtimer)
- [node-red-contrib-schedex](https://flows.nodered.org/node/node-red-contrib-schedex)
- [node-red-node-timeswitch](https://flows.nodered.org/node/node-red-node-timeswitch)
- [node-red-contrib-huemagic](https://flows.nodered.org/node/node-red-contrib-huemagic)
- [node-red-contrib-uibuilder](https://flows.nodered.org/node/node-red-contrib-uibuilder)
- [node-red-dashboard](https://flows.nodered.org/node/node-red-dashboard)

## Prerequisits
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
- [Node Red Docker Image](https://github.com//node-red/node-red-docker)
