# ==================================================================================================
#
# Purpose     : Single image for emacs editor
#
# How To Build:
#
# $ cd <this folder>
# $ docker build -t emacs:latest .
#
# How To Use It
#
# Create two new commands in your OS, one to invoke the emacs-daemon in the docker, the other one to invoke an
# emacsclient (both in background to not open too many terminals). Create a folder on your system and mount it
# as described:
#
# $ docker run \
#     -v <dedicated emacs folder>:/home/emacsserver
#     -v <Any drive to work on>:/<drive letter>
#     ...
#     --rm --name emacs-docker emacs:latest /bin/bash -c "emacs --daemon"  (to be tested)
#
# Author(s)   : Samuele FAVAZZA (sfavazza.github@gmail.com)
# 
# =================================================================================================

FROM debian:bullseye

# local variables used at build time
ARG UNAME=emacsserver
ARG EMACS_BUILD=/home/${UNAME}/emacs_build

# add a new user and change the root password
RUN adduser --disabled-login --gecos "emacs server daemon,,," ${UNAME}; \
    echo "${UNAME}:${UNAME}" | chpasswd; \
    echo "root:root" | chpasswd

# install tools ###############################################################
RUN apt update \
    && apt install -y apt-utils git make file tree man nano

# development libraries
RUN apt update \
    && apt install -y bash-completion build-essential

# enable bash completion
RUN chmod u+x /etc/profile.d/bash_completion.sh && . /etc/profile.d/bash_completion.sh

# the list of dependencies has been found taking inspiration from the official builds of the debian distribution
# of the emacs package, to find it follow the steps below:
# 1. go to the debian package tracker: https://tracker.debian.org/pkg/emacs
# 2. click on the maintainer name
# 3. click on the buildd of interest

# install emacs dependencies
RUN apt update && apt install -y \
    libncurses5-dev texinfo liblockfile-dev librsvg2-dev dbus-x11 git gnupg-agent libgif-dev \
    libtiff-dev libsystemd-dev procps xaw3dg-dev libpng-dev libjpeg-dev libm17n-dev libotf-dev \
    libgpm-dev libdbus-1-dev autoconf automake dpkg-dev quilt debhelper \
    libxaw7-dev sharutils imagemagick libcairo-dev libgmp-dev libgtk-3-dev libgnutls28-dev libxml2-dev \
    libselinux1-dev libharfbuzz-dev libjansson-dev libasound2-dev libmagick++-6.q16-dev libacl1-dev \
    zlib1g-dev fakeroot



# # setup miniconda ###############################################
# COPY --chown=root:root support/Miniconda3-latest-Linux-x86_64.sh /opt/conda_install.sh
# RUN cd /opt; \
#     chmod 744 conda_install.sh; \
#     ./conda_install.sh -b -p ${EMACS_BUILD};

# # add commands to the user path
# ENV PATH="${EMACS_BUILD}/bin:$PATH"

# # initialize the shell to use conda environments
# RUN conda init bash

# # uncomment all alias definitions in the bashrc
# RUN sed -i 's/^#\s*alias\s\+l/alias l/' /root/.bashrc
# RUN sed -i 's/^#\s*\(export\sLS_OPTIONS\)/\1/' /root/.bashrc
