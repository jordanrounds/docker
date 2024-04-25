#!/bin/bash

source '../functions.sh'

app="FileBot Node"
folder="filebot-node"
persist="${LOCAL_PERSIST}/${folder}"
data="${persist}/data"
volume1="${NFS}/filebot"

init $app

create_directory $persist
create_directory $data
create_directory $volume1

create_link $app $persist

write_env LP_DATA $data
write_env LP_VOLUME1 $volume1

