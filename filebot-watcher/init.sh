#!/bin/bash

source '../functions.sh'

app="FileBot Watcher"
folder="filebot-watcher"
persist="${LOCAL_PERSIST}/${folder}"
data="${persist}/data"

init "$app"

create_directory $persist
create_directory $data

create_link "$app" $persist

write_env_prompt COMMAND 'filebot command:'
write_env LP_DATA $data

