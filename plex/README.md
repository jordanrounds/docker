# Plex

[LinuxServer.io](https://docs.linuxserver.io/images/docker-plex/)
[GitHub]()
[DockerHub](https://hub.docker.com/r/linuxserver/plex)

## Network Configuration

To ensure clients (iOS, Apple TV, etc.) connect directly instead of using Plex's bandwidth-limited relay service, configure the following in Plex Web UI under **Settings → Network**:

### Custom Server Access URLs
```
http://10.10.10.40:32400
```
This advertises the local server address to Plex clients.

### LAN Networks
```
10.10.10.0/255.255.255.0
```
Defines which IP ranges are considered "local" for bandwidth/quality purposes.

### Relay
Disable **"Enable Relay"** if you have alternative remote access (e.g., Twingate, VPN). Relay connections are bandwidth-limited and should only be used as a fallback.

## Remote Access

Remote access is handled via Twingate rather than port forwarding. Ensure the `10.10.10.0/24` subnet is configured as a Twingate resource.

Port 32400 is exposed but not forwarded at the router level.

## After Configuration Changes

1. Restart container: `docker-compose restart`
2. On mobile apps: Sign out and sign back in to refresh server discovery

## References

- [Plex Network Settings](https://support.plex.tv/articles/200430283-network/)
- [Accessing a Server through Relay](https://support.plex.tv/articles/216766168-accessing-a-server-through-relay/)
- [Traefik with SSL for Homelab](https://abowden.hashnode.dev/setting-up-traefik-with-ssl-certificates-for-a-homelab)