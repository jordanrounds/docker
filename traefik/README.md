# Traefik Reverse Proxy Setup

## Overview

Traefik v3.2 reverse proxy configuration for home server infrastructure. This setup provides SSL termination, automatic certificate management via Let's Encrypt, and routing for 40+ containerized services.

## Current Configuration

### Version
- **Traefik Version:** v3.2.5 (upgraded from v3.0 on Sep 28, 2025)
- **Container Memory:** Limited to 512MB (with 256MB reservation)

### Network Architecture
- **Frontend Network:** Public-facing services
- **Socket-Proxy Network:** Secure Docker API access via socket-proxy container
- **Domain:** `*.in.rounds.house`

## Files Structure

```
/home/docker/traefik/
├── docker-compose.yaml   # Container configuration with memory limits
├── traefik.yml          # Main Traefik configuration
├── config.yml           # Static route definitions for non-Docker services
└── README.md           # This file
```

## Recent Changes (Sep 28, 2025)

### Memory Leak Fix
Resolved critical memory leak issue where Traefik v3.0 was consuming 10GB+ RAM and crashing the host system.

**Problem:**
- Traefik v3.0 had a known memory leak (GitHub issues #10859, #10864)
- DEBUG logging exacerbated the issue
- Container consumed 82% of system memory (10GB+)

**Solution Applied:**
1. **Upgraded to Traefik v3.2.5** - Contains memory leak fixes and ~50% performance improvements
2. **Disabled debug logging** - Changed from `DEBUG` to `INFO` level
3. **Added memory limits** - 512MB limit with 256MB reservation
4. **Result:** Memory usage reduced from 10GB to ~32MB (99.7% reduction)

## Configuration Details

### Docker Compose (`docker-compose.yaml`)
```yaml
services:
  traefik:
    image: traefik:v3.2
    container_name: traefik
    mem_limit: 512m              # Memory limit to prevent runaway consumption
    mem_reservation: 256m        # Guaranteed memory allocation
    environment:
      DNSIMPLE_OAUTH_TOKEN_FILE: /run/secrets/dnsimple_oauth_token
    ports:
      - '80:80'                  # HTTP
      - '443:443'                # HTTPS
    volumes:
      - ./traefik.yml:/traefik.yml:ro
      - ./config.yml:/config/config.yml:ro
      - letsencrypt:/letsencrypt
    networks:
      - socket-proxy             # Secure Docker API access
      - frontend                 # Service network
```

### Main Configuration (`traefik.yml`)
```yaml
api:
  dashboard: true
  debug: false                   # IMPORTANT: Keep false to prevent memory issues

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https              # Auto-redirect HTTP to HTTPS
  https:
    address: ":443"

log:
  level: INFO                    # Use INFO, not DEBUG (memory optimization)

providers:
  docker:
    endpoint: "tcp://socket-proxy:2375"
    exposedByDefault: false      # Explicit opt-in for services
  file:
    directory: /config           # Static routes from config.yml

certificatesResolvers:
  dnsimple:
    acme:
      email: jrounds@mac.com
      storage: /letsencrypt/acme.json
      dnsChallenge:
        provider: dnsimple
```

### Static Routes (`config.yml`)
Defines routes for non-Docker services including:
- Proxmox VE hosts (pve, zima, mini)
- Home Assistant
- Synology NAS
- Zigbee controller
- UniFi Dream Machine Pro

## SSL Certificates

- **Provider:** Let's Encrypt via DNSimple DNS challenge
- **Wildcard Certificate:** `*.in.rounds.house`
- **Storage:** `/letsencrypt/acme.json` (persistent volume)
- **Auto-renewal:** Handled automatically by Traefik

## Service Integration

Services integrate with Traefik using Docker labels:
```yaml
labels:
  traefik.enable: 'true'
  traefik.http.routers.service-name.rule: 'Host(`service.in.rounds.house`)'
  traefik.http.routers.service-name.entrypoints: 'https'
  traefik.http.routers.service-name.tls: 'true'
  traefik.http.services.service-name.loadbalancer.server.port: '8080'
```

## Monitoring

### Check Status
```bash
# Container status
docker ps | grep traefik

# Memory usage
docker stats traefik --no-stream

# Logs (INFO level)
docker-compose logs -f traefik

# Access dashboard
https://traefik.in.rounds.house
```

### Expected Resource Usage
- **Memory:** 30-150MB under normal load
- **CPU:** < 5% average
- **Container Count:** ~22 services with Traefik labels

## Troubleshooting

### High Memory Usage
1. Check log level is INFO, not DEBUG
2. Verify api.debug is false
3. Consider upgrading to latest v3.2.x if issues persist
4. Memory limits will restart container if exceeded

### Service Not Accessible
1. Verify service has `traefik.enable: 'true'` label
2. Check service is on `frontend` network
3. Review Traefik logs for routing errors
4. Ensure DNS points to server IP

### Certificate Issues
1. Check DNSimple token is valid
2. Verify DNS records exist for domain
3. Review ACME logs in Traefik output
4. Check `/letsencrypt/acme.json` permissions

## Security Notes

- Docker socket access is proxied through `socket-proxy` container
- Dashboard requires authentication (credentials in Docker secrets)
- All HTTP traffic auto-redirects to HTTPS
- TLS minimum version: 1.2

## Maintenance

### Update Traefik
```bash
cd /home/docker/traefik
docker-compose pull
docker-compose up -d
```

### Rotate Certificates (Manual)
```bash
# Delete existing certificates
docker-compose exec traefik rm /letsencrypt/acme.json
# Restart to regenerate
docker-compose restart traefik
```

### Generate Basic Auth Password
```bash
# For Docker secrets file (no escaping needed)
htpasswd -nB username
```

## References

- [Traefik v3.2 Documentation](https://doc.traefik.io/traefik/)
- [GitHub Issue #10859 - Memory Leak](https://github.com/traefik/traefik/issues/10859)
- [Traefik v3.2 Release Notes](https://traefik.io/blog/traefik-proxy-v3-2-a-munster-release)