# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive Docker-based home server infrastructure managing 40+ containerized services. The repository uses Docker Compose to orchestrate services across media management, home automation, monitoring, and development tools.

## Architecture

### Network Architecture
- **frontend**: Services exposed via Traefik reverse proxy
- **backend**: Internal services communication  
- **socket-proxy**: Isolated network for Docker socket access

### Storage Architecture
- **NFS Volumes**: Shared media storage from 10.10.10.50
- **Named Volumes**: Service configurations and persistent data (pattern: `service_config`, `service_data`)
- **Environment Variables** (defined in shell environment):
  - `$DOCKER=/home/docker`: Base directory for all services
  - `$DATA=/home/docker/.data`: Local data directory (not backed up)
  - `$SECRETS=/home/docker/.secrets`: Docker secrets directory
  - `$NFS=/mnt/rounds-nas`: Network storage mount point

### Service Categories
1. **Media Stack**: Plex, Sonarr/Radarr (with 4K variants), Bazarr, qBittorrent, SABnzbd, Recyclarr, Filebot
2. **Home Automation**: Node-RED, Mosquitto, Zigbee2MQTT, Z-Wave JS UI, Ring-MQTT, Insteon-MQTT
3. **Infrastructure**: Traefik, Bind9, PostgreSQL, MariaDB, Nginx, Samba
4. **Monitoring**: Portainer, Grafana, InfluxDB2, Loki, Promtail, WhatsUpDocker, Tautulli
5. **Development**: Code-server, pgAdmin, File-browser, Syncthing

## Common Commands

### Service Management
```bash
# Navigate to service
cd $DOCKER/service-name

# Initialize service (if init.sh exists)
./init.sh

# Start service
./start.sh
# OR
docker-compose up -d

# Restart service
docker-compose down && docker-compose up -d

# View logs
docker-compose logs -f

# Force recreate with latest image
docker-compose up --force-recreate --build -d
```

### Docker Maintenance
```bash
# Prune old images
docker image prune -af

# Prune volumes (CAREFUL)
docker volume prune

# List and remove dangling volumes
docker volume ls -qf dangling=true
docker volume rm $(docker volume ls -qf dangling=true)
```

### Helper Functions (from /home/docker/functions.sh)
Source these functions in init.sh scripts with: `source ../functions.sh`

- `init "app_name"`: Print initialization banner
- `create_directory "path"`: Create directory if it doesn't exist
- `create_link "app_name" "path"`: Create symlink named 'persist-data' to path
- `create_secret_file "$SECRETS" "filename" "prompt"`: Interactively create secret files
- `write_env "VAR_NAME" "value"`: Add/update variable in .env file
- `write_env_prompt "VAR_NAME" "prompt"`: Interactively add/update .env variable
- `start_container "app_name"`: Down, then force recreate container
- `cleanup_old_images`: Prune unused Docker images

## Key Patterns

### Docker Compose Structure
- Each service has its own directory with `docker-compose.yaml`
- Many services include `init.sh` and `start.sh` scripts
- Services use external networks and volumes
- Consistent labeling for Traefik routing and WUD monitoring

### Secret Management
- File-based secrets stored in `${SECRETS}/` directory (`/home/docker/.secrets`)
- Naming pattern: `service.type.identifier` (e.g., `mosquitto.password.mos`)
- Referenced as external secrets in docker-compose.yaml:
  ```yaml
  secrets:
    secret_name:
      file: ${SECRETS}/service.secret.name
  ```
- Pattern: `_FILE` environment variables for secret injection (e.g., `POSTGRES_PASSWORD_FILE`)
- Use `create_secret_file()` function from functions.sh to create secrets interactively

### Traefik Integration
- Services exposed via labels
- Pattern: `traefik.http.routers.service.rule: 'Host(\`service.in.rounds.house\`)'`
- SSL certificates via Let's Encrypt
- Domain: `*.in.rounds.house`

### Update Monitoring
- WhatsUpDocker (WUD) labels on all containers
- Version pattern matching: `wud.tag.include: '^\d+\.\d+\.\d+$$'`
- Automatic update checking

## Important Considerations

### Security
- Docker socket exposure limited to socket-proxy network
- Network segregation enforced
- Consistent PUID/PGID (1000) across services
- Some services require host networking (Samba, Bind9)

### Volume Management
- Configuration and persistent data in named Docker volumes
- Media files on NFS shares (`$NFS`)
- Temporary/local data in `$DATA` (not backed up)

### Service Dependencies
- Many services depend on Traefik for routing
- Media services share NFS volumes
- Home automation services connect via MQTT
- Databases used by multiple services

## Development Workflow

### Setting Up Infrastructure
Before adding services, ensure core networks exist:
```bash
docker network create frontend
docker network create backend
docker network create socket-proxy
```

### Adding a New Service
1. Create directory: `mkdir $DOCKER/service-name && cd $DOCKER/service-name`
2. Create `docker-compose.yaml` with:
   - External networks (frontend/backend/socket-proxy)
   - Named volumes for config/data
   - Traefik labels if web-accessible
   - WUD labels for update monitoring
   - Security options: `no-new-privileges:true`
   - Resource limits (mem_limit, mem_reservation)
3. Create `init.sh` (optional but recommended):
   ```bash
   #!/bin/bash
   source ../functions.sh

   init "Service Name"
   create_secret_file "$SECRETS" "service.secret.name" "Enter secret:"
   write_env "VAR_NAME" "value"
   start_container "Service Name"
   cleanup_old_images
   ```
4. Make executable: `chmod +x init.sh`
5. Run initialization: `./init.sh`

### Modifying Existing Services
- Always check for init.sh/start.sh scripts before manual changes
- Preserve volume mappings (data will be lost if changed)
- Maintain network assignments (services may break if removed)
- Update WUD labels if changing image tags

### Testing Changes
```bash
# Validate compose file syntax
docker-compose config

# Start service
docker-compose up -d

# Check logs for errors
docker-compose logs -f

# If web-accessible, verify Traefik routing
curl -I https://service.in.rounds.house

# Verify volumes persisted correctly
docker volume inspect service_config
```