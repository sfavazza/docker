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
#     -e HOME=/u/
#     --rm --name emacs-docker emacs:latest /bin/bash -c "emacs --daemon"  (to be tested)
#
# LINUX VERSION FOR GUI
# sudo docker run --rm -ti --cap-add=NET_ADMIN \
#     -v /tmp/.X11-unix:/tmp/.X11-unix:ro
#     --net=host -e DISPLAY=:0 emacs:latest
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

COPY --chown=root:root support/emacs-*.tar.gz ${EMACS_BUILD}/${EMACS_ARCHIVE}
WORKDIR ${EMACS_BUILD}
RUN tar -xvf ${EMACS_ARCHIVE}


# install emacs
RUN cd emacs-* && ./configure --with-x --prefix=${EMACS_BIN} && make && make install
RUN cd emacs-* && make clean

# save space by removing the installation file
RUN cd ${EMACS_BUILD}/.. && rm -rf ${EMACS_BUILD}


# add commands to the user path
WORKDIR ${EMACS_ROOT}
USER ${UNAME}
ENV PATH="${EMACS_BIN}/bin:$PATH"

# restore bash default setting
RUN cp /etc/skel/.bashrc ~/
# uncomment all alias definitions in the bashrc
RUN sed -i 's/^#\s*alias\s\+l/alias l/' ~/.bashrc
RUN sed -i 's/^#\s*\(export\sLS_OPTIONS\)/\1/' ~/.bashrc
