# Eclipse Mosquitto Docker Container
This project is for the setup of a Eclipse Mosquitto container using docker-compose. It uses the local-persist plugin to configure the volumes and using the mosquitto.conf file sets up authentication on ports 1883 and 9001

## Getting Started
By default this will create a user named mos. If you'd like to use something different, the username is defined in the .env file.

The init.sh script will create the empty files that are needed for the secrets as well as a .env file to populate the MOSQUITTO_USERNAME variable.

## Prerequisits
**Environment Variables**
- MOSQUITTO_USERNAME is the default username that will be added
- LOCAL_PERSIST is the root of where data is persisted
- SECRETS is the root of where the secret files are stored
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

## User Management
If you want to add additional users, delete, or change passwords. You can run the mosquitto-user.sh script, and it will handle running the mosquitto_passwd commands in the container and restarting the mosquitto process.

## Reference / Acknowledgments
- [Mosquitto Docker Image](https://github.com/thelebster/example-mosquitto-simple-auth-docker)
