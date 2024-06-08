#!/bin/bash

source '../functions.sh'

app="Homepage"
folder="homepage"
persist="${LOCAL_PERSIST}/${folder}"
config="${persist}/config"

init $app

create_directory $persist
create_directory $config

create_link $app $persist

write_env LP_CONFIG $config

