#!/bin/bash
# Utility to populate the script folder of a docker-file context with some common (versioned)
# shell-script (in "common_scripts/") useful in the image being built by the target docker context.

# list of environments requiring the common_scripts
REQUIRE_COMMON_SCRIPTS_SUB_FOLDER=(
    emacs
    statistics
)

# copy from general folder
for context in ${REQUIRE_COMMON_SCRIPTS_SUB_FOLDER[@]}; do
    _DST=dockerfiles/$context/scripts
    mkdir -p $_DST
    cp -u -v common_scripts/* $_DST
done
