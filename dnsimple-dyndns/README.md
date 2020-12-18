# DNSimple Dynamic DNS
This project is for the setup of a DNSimple Dynamic DNS container using docker-compose. It is very basic and runs a script through a cron job to update DNS regularly using the DNSimple API with the current IP of the host's public IP.

The sole purpose of the container is to run a cron job every 15 minutes to execute the dnsimple-updatedns script.

## Getting Started
You will need your account id, zone_id, token, and the record ids from DNSimple. Those values need to be placed in the .secrets directory in the corresponding files.

The init.sh script will create the empty files that are needed for the secrets.

## Prerequisits
The dnsimple-updatedns script is assuming you are using a wildcard domain. If not remove that record id as well as the second curl command.

**Environment Variables**
- TZ is the timezone
- SECRETS is the root of where the secret files are stored

**Secrets**
- .secrets/dnsimple.account_id - this can be found by clicking "account" and grabbing it from the url https://dnsimple.com/a/[your_account_id]/account
- .secrets/dnsimple.zone_id - this is the name of the domain - ie: yourdomain.com
- .secrets/dnsimple.token - this can be by clicking account -> automation, then under API Tokens click new, and after that give it a name and click "Generate Token", next copy the token because it will never be displayed again
- .secrets/sndimple.record_id - this can be found by clicking domains -> the domain -> DNS -> DNS Records Manage -> Edit (pencil) of the main domain A record
- .secrets/sndimple.wildcard_record_id - this can be found by clicking domains -> the domain -> DNS -> DNS Records Manage -> Edit (pencil) of the wildcard domain A record

## Installing
Execute setup.sh which will bring the container up.

**Alternatively**

```
docker-compose up --force-recreate --build -d
docker image prune -f
```