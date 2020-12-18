# NGINX Docker Container
This project is for the setup of an NGINX container using docker-compose. It generates its cert using a dns plugin for DNSimple by default but can be configured to use a different one. It also is configured to use wildcard subdomains. It uses the local-persist plugin to configure the volumes.

[docker-swag](https://github.com/linuxserver/docker-swag)

## Getting Started
Outside of the environment variable and secret configuration the dns plugin will need to be configured. By default its setup to us dnsimple and the file needs to have the token added to it

Once the container is tarted the file to be edited will be accessible through the volume configured for the container. The file will be located here:

.local-persist/nginx/config/dns-conf/dnsimple.ini

The init.sh script will create the empty files that are needed for the secrets as well as a .env file to populate the various environment variables.

## Prerequisits
**Environment Variables**
- SUBDOMAINS is set to wildcard
- VALIDATION is set to dns because of using a dnsplugin
- DNSPLUGIN is by default set to dnsimple, but there are others documented on linuxserver letsencrypt readme
- LOCAL_PERSIST is the root of where data is persisted
- SECRETS is the root of where the secret files are stored
- TZ is the timezone

**Secrets**
- .secrets/nginx.url - the url to yourdomain.com
- .secrets/nginx.email - the email address to send cert expiration notifications to

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
[docker-swag](https://github.com/linuxserver/docker-swag) (formerly the lets-encrypt image)
