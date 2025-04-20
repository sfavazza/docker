#!/usr/bin/env bash

set -euxo pipefail

# This script can be executed from a docker container, where the "dockerhostgroup" exists if the
# "docker" group ID differs from the host one. If executed from the host the "dockerhostgroup" won't
# exist and the original "docker" GID will be taken.
docker_gid="$( (getent group dockerhostgroup || getent group docker) | awk -F ':' '{ print $3 }' )"

read -p 'spacemacs container tag: ' container_tag

docker build \
       --build-arg HOST_DOCKER_GID="$docker_gid" \
       --build-arg GID="$(id -g)" \
       --build-arg UID="$(id -u)" \
       --build-arg DISTRO_NAME="$(lsb_release --id | awk '{ print tolower($3) }')" \
       --build-arg DISTRO_VER="$(lsb_release --release | awk '{ print $2 }')" \
       -t spacemacs:"$container_tag" .
