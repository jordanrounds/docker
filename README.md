# Full Docker Setup
This is my entire Docker setup. Each directory contains a docker-compose file to setup the containers.

There is a docker-setup.sh script include that will setup everything post install of docker.

This includes the creation of all directories, installation of the local persist plugin, and setting some environment variables.

Most of these containers are in some way related to Home Assitant or home automation generally.

## Reference
[Docker Secrets](https://docs.docker.com/compose/compose-file/#secrets)
[Local Persist](https://github.com/MatchbookLab/local-persist)