# PostgreSQL

## Links
(Docker Hub)[https://hub.docker.com/_/postgres]
(GitHub)[https://github.com/docker-library/postgres]

## Docker Compose

### Notes
- POSTGRES_DB - .env file
- POSTGRES_USER - .env file
- POSTGRESS_PASSWORD - docker secret

### Volumes
- postgresql_data
- config/postgresql.conf is bind mounted
- config/pg_hba.conf is bind mounted

### External Connections
- in the postgresql.conf added listen_addresses = '*'
- the pb_hba.conf is a copy of the default with one additional line
   - allows anything with an internal ip to connect
   - host    all             all             192.168.10.0/24         md5