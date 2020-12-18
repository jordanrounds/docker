# Samba Docker Container
This project is for the setup of a [ring-mqtt](https://github.com/tsightler/ring-mqtt) container using docker-compose. It uses the local-persist plugin to configure the volumes.

## Getting Started
The container requires the creation of a Ring refresh token. The easiest way to get that is by running it from the bundled CLI using:

```
docker run -it --rm --entrypoint /app/ring-mqtt/node_modules/ring-client-api/ring-auth-cli.js tsightler/ring-mqtt
```

There is more info here: [Authentication](https://github.com/tsightler/ring-mqtt#authentication)


The init.sh script will create the empty files that are needed for the secrets as well as a .env file to populate the various environment variables.

## Prerequisits
**Environment Variables**
- TINI_SUBREAPER:
- NMBD: ${NMBD}
- USER_FILE is the path to the secret file containing the ```username;password```
- SHARE is the configuration for the share, and documented [here](https://github.com/dperson/samba)
- USERID is the user id for the default user
- GROUPID is the group id for the default user
- WORKGROUP is the name of the workgroup (domain) samba should use
- TZ is the timezone
- SECRETS is the root of where the secret files are stored

**Secrets**
- .secrets/mosquitto.password.ring - The passwrod for the MQTT user (ring is the default name)
- .secrets/ring-mqtt.token - The refresh token received after authenticating with 2FA

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
- [ring-mqtt](https://github.com/tsightler/ring-mqtt)