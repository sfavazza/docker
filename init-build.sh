#!/bin/bash

# list of environments requiring the common_scripts
REQUIRE_COMMON_SCRIPTS=(emacs statistics)

# copy from general folder
for context in ${REQUIRE_COMMON_SCRIPTS[@]}; do
    _DST=dockerfiles/$context/scripts
    mkdir -p $_DST
    cp common_scripts/* $_DST
done
