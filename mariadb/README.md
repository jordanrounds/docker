# MariaDB Docker Container
This project is for the setup of a MariaDB container using docker-compose. It uses the local-persist plugin to configure the volumes. Its intended to be used as the database for a Home Assistant Install. It will create a database named hass along with a user also named hass.

## Getting Started
You will need to set your root user password as well as the db user's password. You will need to put

- .secrets/dnsimple.account_id - this can be found by clicking "account" and grabbing it from the url https://dnsimple.com/a/[your_account_id]/account
- .secrets/dnsimple.zone_id - this is the name of the domain - ie: yourdomain.com

The init.sh script will create the empty files that are needed for the secrets as well as a .env file to populate the MYSQL_DATABASE and MYSQL_USER variables.

## Prerequisits
**Environment Variables**
- MYSQL_DATABASE is the name of the database that will be created
- MYSQL_USER is the username for the database that will be created
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

## Upgrading the Image
TODO: Need to verify that these steps are correct

### Step 1: Stop and backup the currently running container
Stop the currently running container using the command

```
docker-compose stop
```

Next, take a snapshot of the persistent volume /path/to/mariadb-persistence using:

```
rsync -a /path/to/mariadb-persistence /path/to/mariadb-persistence.bkp.$(date +%Y%m%d-%H.%M.%S)
```

You can use this snapshot to restore the database state should the upgrade fail.

### Step 2: Remove the currently running container

```
docker-compose rm -v
```

### Step 3: Run the new image
Re-create your container from the new image.

```
docker-compose up -d
```

## Reference / Acknowledgments
- [Official MariaDB Docker Image](https://github.com/docker-library/mariadb)
