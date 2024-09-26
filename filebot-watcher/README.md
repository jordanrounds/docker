### Write the license to the volume

docker run --rm -it -v filebot-watcher_data:/data -e PUID=1000 -e PGID=1000 rednoah/filebot --license

### Paste in the license key once in the container

### License will be written to data/filebot/license.txt