**Sync all configs**
```
docker exec -it recyclarr recyclarr sync
```

**List all templates**
```
docker exec -it recyclarr recyclarr config list templates
```

**Generate config from template**
template_name: get it from the list of templates in the above command
```
docker exec -it recyclarr recyclarr config create --template <template_name>
```

**List namings for service**
service: `radarr`, `sonarr`
```
docker exec -it recyclarr recyclarr list naming <service>
```