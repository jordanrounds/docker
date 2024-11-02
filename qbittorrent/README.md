# Qbittorrent

## Links

(LinuxServer.io)[https://docs.linuxserver.io/images/docker-qbittorrent/]
(DockerHub)[]
(GitHub)[https://github.com/linuxserver/docker-qbittorrent]


## Theme

Used ThemePark
(Docs)[https://docs.theme-park.dev/themes/qbittorrent/]
(Theme)[https://github.com/catppuccin/qbittorrent]

Compose changes:
```yaml
DOCKER_MODS: 'ghcr.io/themepark-dev/theme.park:qbittorrent'
QBITTORRENT_VERSION: '5.0.0'
TP_COMMUNITY_THEME: 'true'
TP_THEME: catppuccin-mocha
TP_DISABLE_THEME: 'false'
```

Set custom http headers in qbittorrent web ui:

```
content-security-policy: default-src 'self'; style-src 'self' 'unsafe-inline' theme-park.dev raw.githubusercontent.com use.fontawesome.com; img-src 'self' theme-park.dev raw.githubusercontent.com data:; script-src 'self' 'unsafe-inline'; object-src 'none'; form-action 'self'; frame-ancestors 'self'; font-src use.fontawesome.com;
```