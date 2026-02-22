# Traefik Reverse Proxy Setup

## Overview

Traefik v3.2 reverse proxy configuration for home server infrastructure. This setup provides SSL termination, automatic certificate management via Let's Encrypt, and routing for 40+ containerized services.

## Current Configuration

### Version
- **Traefik Version:** v3.6.7 (upgraded from v3.5.3 on Jan 31, 2026)
- **Container Memory:** Limited to 1GB (with 256MB reservation)

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

## Recent Changes (Jan 31, 2026)

### UniFi Dream Machine Pro (UDMP) Memory Leak

**Problem:**
Traefik v3.5.3 experienced severe OOM errors when proxying requests to the UniFi Dream Machine Pro controller. Each request to the UDMP backend leaked ~250-400MB of memory that was never released, causing Traefik to hit its memory limit within minutes.

**Root Cause:**
HTTP/2 connection handling issue between Traefik and the UDMP controller. The UDMP uses HTTP/2, and Traefik's connection pooling/reuse was not releasing memory properly after requests completed.

**Diagnosis:**
- Memory stable at ~20MB when idle
- Each request to `https://unifi.in.rounds.house` caused 250-400MB memory growth
- Memory was NOT released after requests completed or after GC wait
- Other HTTPS backends (Proxmox, etc.) did not exhibit this behavior
- Issue persisted in v3.6.7 but was reduced (~50MB per request)

**Solution Applied:**
1. **Upgraded to Traefik v3.6.7** - Reduced leak severity
2. **Added `nohttp2` serversTransport** in `config.yml` for UDMP backend:
   ```yaml
   http:
     serversTransports:
       nohttp2:
         disableHTTP2: true
         insecureSkipVerify: true
   ```
3. **Applied transport to UniFi service:**
   ```yaml
   unifi:
     loadBalancer:
       serversTransport: nohttp2@file
       servers:
         - url: "https://udmp.metal.in.rounds.house"
   ```
4. **Removed UniFi widget from Homepage** - Prevents repeated API calls that trigger the leak

**Workaround:**
If accessing UniFi directly via `https://unifi.in.rounds.house`, the `nohttp2` transport mitigates the leak. For Homepage integration, the UniFi widget should remain disabled until Traefik fixes the underlying HTTP/2 issue.

**Related Issues:**
- [GitHub Issue #11986 - HTTP/2 connection issues](https://github.com/traefik/traefik/issues/11986)
- [GitHub Issue #10859 - Memory leak in Traefik v3](https://github.com/traefik/traefik/issues/10859)

---

## Previous Changes (Sep 28, 2025)

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
    image: traefik:v3.6.7
    container_name: traefik
    mem_limit: 1g               # Memory limit to prevent runaway consumption
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
- **Memory:** 25-50MB under normal load (avoid UniFi widget to prevent spikes)
- **CPU:** < 5% average
- **Container Count:** ~22 services with Traefik labels

## Troubleshooting

### High Memory Usage
1. Check log level is INFO, not DEBUG
2. Verify api.debug is false
3. Check if UniFi/UDMP requests are triggering the leak (see Jan 2026 notes)
4. Memory limits will restart container if exceeded

### UniFi/UDMP Memory Leak
If memory spikes when accessing UniFi controller:
1. Ensure `nohttp2` serversTransport is applied to the unifi service in `config.yml`
2. Avoid using Homepage UniFi widget (triggers repeated API calls)
3. Access UniFi directly at the UDMP IP if needed to bypass Traefik

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

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [GitHub Issue #10859 - Memory Leak](https://github.com/traefik/traefik/issues/10859)
- [GitHub Issue #11986 - HTTP/2 Connection Issues](https://github.com/traefik/traefik/issues/11986)
- [ServersTransport Documentation](https://doc.traefik.io/traefik/routing/services/#serverstransport)