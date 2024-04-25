#!/bin/bash

source '../functions.sh'

app="FileBot"
folder="filebot"
persist="${LOCAL_PERSIST}/${folder}"
config="${persist}/config"
storage="${persist}/storage"
watch="${persist}/watch"
output="${persist}/output"

init $app

create_directory $persist
create_directory $config
create_directory $storage
create_directory $watch
create_directory $output

create_link $app $persist

write_env LP_CONFIG $config
write_env LP_STORAGE $storage
write_env LP_WATCH $watch
write_env LP_OUTPUT $output

