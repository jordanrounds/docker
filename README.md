# Docker Setup

## Commands

Remove all images not associated with a container
```bash
docker image prune
```

Remove anonymous local volumes not used by at least one container
```bash
docker volume prune
```

List unused named volumes and anonymous
```bash
docker volume ls -f dangling=true
```

Remove anonymous and named dangling volumes
```bash
docker volume rm $(docker volume ls -qf dangling=true)
```
## Reference
[Docker Secrets](https://docs.docker.com/compose/compose-file/#secrets)