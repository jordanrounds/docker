#!/bin/bash

source '../functions.sh'

app="QBitTorrent"
folder="qbittorrent"
persist="${LOCAL_PERSIST}/${folder}"
config="${persist}/config"
downloads="${persist}/downloads"

init $app

create_directory $persist
create_directory $config
create_directory $downloads

create_link $app $persist

write_env LP_DOWNLOADS $downloads
write_env LP_CONFIG $config

