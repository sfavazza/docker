#!/usr/bin/env bash

set -euxo pipefail

# CAUTION: this script MUST be executed only from the host as ID for the docker group on the host
# could correspond, in the docker, to:
# - no group at all
# - to another group which happens to have the same ID as the docker group on the host
#
# In the second scenario the dockerhostgroup won't exist as an already valid GID is present in the
# image, but the 'docker' group in the image is not guaranteed to feature the same GID as the host
# GID.
docker_gid="$(stat -c '%g' /var/run/docker.sock)"

# CAUTION: another reason to run from a host terminal is that it is not guaranteed to have all host
# OS-variables defined in the spacemacs container.
if [ -f "/.dockerenv" ]; then
    echo "ERROR: this script shall be executed from host, not inside a container"
    return 1
fi

# TEMP: keep in case discover an untested case, the one where user id corresponds to an user
# unrecognized by the Emacs container.
# docker_gid="$( (getent group dockerhostgroup || getent group docker) | awk -F ':' '{ print $3 }' )"

read -rp 'spacemacs container tag: ' container_tag

# NOTE: suspend statement printing while selecting the password
set +x
user_password=""
check_password="check"
while [ "$user_password" != "$check_password" ]; do
    read -srp 'select password: ' user_password
    echo ""
    read -srp 'retype password: ' check_password
    echo ""
done
export TEMP_PASSWORD=$user_password
set -x

docker build \
       --secret id=usr-password,env=TEMP_PASSWORD \
       --build-arg HOST_DOCKER_GID="$docker_gid" \
       --build-arg GID="$(id -g)" \
       --build-arg UID="$(id -u)" \
       --build-arg DISTRO_NAME="$(lsb_release --id | awk '{ print tolower($3) }')" \
       --build-arg DISTRO_VER="$(lsb_release --release | awk '{ print $2 }')" \
       -t spacemacs:"$container_tag" .
