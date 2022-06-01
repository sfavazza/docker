# ==================================================================================================
#
# Purpose     : Single image for emacs editor
#
# How To Build:
#
# $ cd <this folder>
# $ docker build -t emacs_docker:latest .
#
# How To Use It
#
# Create two new commands in your OS, one to invoke the emacs-daemon in the docker, the other one to invoke an
# emacsclient (both in background to not open too many terminals). Create the following structure:
# - store
#   |- init_emacs.el: dot-emacs file being loaded by the .emacs file in the container
#   |- .emacs.d: emacs home directory
#   |- emacs_git: org-based configuration
#   |- configs: folder containing optional tool configurations files (e.g. .gitconfig, .ssh (folder), etc..)
#
# The files found in "configs" folders are automatically copied with the same name in the home-folder of the
# docker container from the ".emacs" in it.
#
# IMPORTANT: remove the old emacs-server authentication file rm -rf <path to docker .emacs.d>/.emacs.d/server/*
# 
# WINDOWS VERSION
# $ docker run --rm --name emacs_docker \
#     -v <path to the "store" folder>:/home/emacsserver/store \
#     -v <Any drive to work on>:/<drive letter> <-- any drive to work on
#     ...
#     -e DISPLAY=<display address>:0.0
#     emacs_docker:latest emacs --fg-daemon
#
# LINUX VERSION FOR GUI
# sudo docker run --rm --name emacs_docker \
#     -v <path to the "store" folder>:/home/emacsserver/store \
#     -v <host root fs>:/orig \
#     -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
#     --net=host \
#     -e DISPLAY=:0 \
#      emacs_docker:latest emacs --fg-daemon
#
# With the foreground-daemon option the docker will remain runnuning in background as the emacs daemon keeps its
# terminal busy. Mapping the root to a volume in the container allows full access to the host fs.
#
# The following are useful shortcuts that can be defined in ".bashrc":
#
#  alias dck_emacsserver='docker run --rm --name emacs_docker -v ~/git/emacs_store/:/home/emacsserver/store -v /:/orig -v /tmp/.X11-unix:/tmp/.X11-unix:ro --net=host -e DISPLAY=:0 emacs_docker:latest emacs --fg-daemon'
# alias dck_emacsserver_bash='docker exec -ti emacs_docker bash'
# alias dck_emacsserver_clean='rm ~/git/emacs_store/.emacs.d/server/*'
#
# The client can be easily invoked with the following command:
#
# docker exec -d emacs_docker emacsclient -c -f /home/emacsserver/store/.emacs.d/server/fermoposta
# --------------------------------------------------------------------------------------------------------------
# 
#
# Author(s)   : Samuele FAVAZZA (sfavazza.github@gmail.com)
# 
# =================================================================================================

FROM debian:bullseye

# local variables used at build time
ARG UNAME=emacsserver
ARG EMACS_ROOT=/home/${UNAME}
ARG EMACS_BUILD=${EMACS_ROOT}/emacs_build
ARG EMACS_ARCHIVE=emacs.tar.gz
ARG EMACS_BIN=${EMACS_ROOT}/emacs_install

# add a new user and change the root password
RUN adduser --disabled-login --gecos "emacs server daemon,,," ${UNAME}; \
    echo "${UNAME}:${UNAME}" | chpasswd; \
    echo "root:root" | chpasswd

# install basic tools
RUN apt update \
    && apt install -y apt-utils git make file tree man nano
RUN apt update \
    && apt install -y bash-completion build-essential

# enable bash completion
RUN chmod u+x /etc/profile.d/bash_completion.sh && . /etc/profile.d/bash_completion.sh

# the list of dependencies has been found taking inspiration from the official builds of the debian distribution
# of the emacs package, to find it follow the steps below:
# 1. go to the debian package tracker: https://tracker.debian.org/pkg/emacs
# 2. click on the maintainer name
# 3. click on the build of interest

# install emacs dependencies
RUN apt update && apt install -y \
    libncurses5-dev texinfo liblockfile-dev librsvg2-dev dbus-x11 git gnupg-agent libgif-dev \
    libtiff-dev libsystemd-dev procps xaw3dg-dev libpng-dev libjpeg-dev libm17n-dev libotf-dev \
    libgpm-dev libdbus-1-dev autoconf automake dpkg-dev quilt debhelper \
    libxaw7-dev sharutils imagemagick libcairo-dev libgmp-dev libgtk-3-dev libgnutls28-dev libxml2-dev \
    libselinux1-dev libharfbuzz-dev libjansson-dev libasound2-dev libmagick++-6.q16-dev libacl1-dev \
    zlib1g-dev fakeroot

# install emacs
COPY --chown=root:root support/emacs-*.tar.gz ${EMACS_BUILD}/${EMACS_ARCHIVE}
WORKDIR ${EMACS_BUILD}
RUN tar -xvf ${EMACS_ARCHIVE}
RUN cd emacs-* && ./configure --with-x --prefix=${EMACS_BIN} && make && make install
RUN cd emacs-* && make clean

# save space by removing the installation file
RUN cd ${EMACS_BUILD}/.. && rm -rf ${EMACS_BUILD}

# python 3.9 is included, install pip and install support packges for elpy
RUN apt update \
    && apt install -y python3-pip python3-venv \
    && python3 -m pip install --upgrade pip
RUN python3 -m pip install mypy pylint flake8 ipython remote-pdb pre-commit
RUN ln -s /usr/bin/python3 /usr/bin/python

# add all GNU project public keys to prevent any issue with the installation of the emacs packages
RUN curl --verbose --output ~/_gnuring.gpg https://ftp.gnu.org/gnu/gnu-keyring.gpg \
    && gpg --import ~/_gnuring.gpg

# install hunspell, configure the locale to select a default dictionary
ENV LANG="en_US.UTF-8"
RUN apt update && apt install -y hunspell hunspell-en-us hunspell-it

# add a defualt ".emacs" file to the image home dir such that the hosted one is read from the store
COPY --chown=${UNAME}:${UNAME} .emacs ${EMACS_ROOT}/

# add commands to the user path
WORKDIR ${EMACS_ROOT}
ENV PATH="${EMACS_BIN}/bin:${EMACS_ROOT}/.local/bin:$PATH"

RUN apt update && apt install -y \
    htop \
    git-lfs

# uncomment all alias definitions in the bashrc
# NOTE: the "+" must be ecaped otherwise it is treated as a normal character
RUN \
    cp /etc/skel/.bashrc ${EMACS_ROOT}/ \
    && sed -i 's/^#\s*alias\s\+l/alias l/' ${EMACS_ROOT}/.bashrc \
    && sed -i "s/ll='ls/ll='ls -a/" ${EMACS_ROOT}/.bashrc \
    && sed -i 's/^#\s*\(export\sLS_OPTIONS\)/\1/' ${EMACS_ROOT}/.bashrc

USER ${UNAME}:${UNAME}