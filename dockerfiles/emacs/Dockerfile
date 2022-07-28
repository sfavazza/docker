# ==================================================================================================
#
# Purpose     : Single image for emacs editor
#
# How To Build:
#
# $ cd <this folder>
# $ docker build --build-arg GID=$(id -g) --build-arg UID=$(id -u) -t emacs_docker:latest .
#
# Where GID and UID are required only if it is required that the default user in the docker image
# inherits the same rights as the user building the image.
#
# How To Use It
#
# Create two new commands in your OS, one to invoke the emacs-daemon in the docker, the other one to invoke an
# emacsclient (both in background to not open too many terminals). Create the following structure:
# - store
#   |- init_emacs.el: dot-emacs file being loaded by the .emacs file in the container
#   |- your GPG key to use for the GCM (it shall end in .gcm), the script is in this repo under
#   |  dockerfiles/emacs/support/initscript.sh
#   |- precommit_cache: folder where pre-commit initialize its environment (faster over multiple emacs server
#   |  invocations)
#   |- .emacs.d: emacs home directory
#   |- emacs_git: org-based configuration
#   `- configs: folder containing optional tool configurations files (e.g. .gitconfig, .ssh (folder), etc..)
#
# The files found in "configs" folders are automatically copied with the same name in the home-folder of the
# docker container from the ".emacs" in it.
#
# IMPORTANT: remove the old emacs-server authentication file rm -rf <path to docker .emacs.d>/.emacs.d/server/*
#
# $ docker run --rm --name emacs_docker \
#     -v <path to the "store" folder>:/home/emacsserver/store \
#     -v <virtual env folder>:/home/emacsserver/.virtualenvs \
#     -v precommit_cache:/home/emacsserver/.cache
#     -e DISPLAY=<display address>:0
# (linux)
#     -v <host root fs>:/orig \
#     -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
#     --net=host \
# -------
# (windows)
#     -v <Any drive to work on>:/<drive letter> <-- any drive to work on
# ---------
#     ...
#     emacs_docker:latest emacs --fg-daemon
#
# The display address should be the one of the machine hosting a X11-server. The value after the colon is the
# display number, when '0' the default display is used.
#
# With the foreground-daemon option the docker will remain runnuning in background as the emacs daemon keeps its
# terminal busy. Mapping the root to a volume in the container allows full access to the host fs.
#
# To complete the setup, after starting the emacs-server make sure to execute, as super-user, the initialization
# script (initscript.sh) as root in a separate terminal.
#
# The following are useful shortcuts that can be defined in ".bashrc":
#
# alias dck_emacsserver='docker run --rm --name emacs_docker -v ~/git/emacs_store/:/home/emacsserver/store -v /:/orig -v /tmp/.X11-unix:/tmp/.X11-unix:ro --net=host -e DISPLAY=:0 emacs_docker:latest emacs --fg-daemon'
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

# Default group and user IDs, to build the container having the same rights of the user building it. Provide the
# desired values via the docker-build command.
ARG GID=1000
ARG UID=1000

# local variables used at build time
ARG UNAME=emacsserver
ARG EMACS_HOME=/home/${UNAME}
ARG EMACS_BUILD=${EMACS_HOME}/emacs_build
ARG EMACS_ARCHIVE=emacs.tar.gz
ARG EMACS_BIN=${EMACS_HOME}/emacs_install

# add the user group
RUN groupadd --gid ${GID} ${UNAME}
# add a new user and change the root password
RUN useradd \
  -d ${EMACS_HOME} --create-home \
  # this option is important to prevent the command from creating huge files (which make the docker builder
  # hang) when the GID/UID values are big.
  --no-log-init \
  --gid ${GID} --uid ${UID} \
  --skel /etc/skel --shell /bin/bash \
  ${UNAME}
RUN echo "${UNAME}:${UNAME}" | chpasswd && echo "root:root" | chpasswd

# install basic tools
RUN apt update \
    && apt install -y apt-utils git make file tree man nano
RUN apt update \
    && apt install -y bash-completion build-essential sudo

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
# NOTE: install the bare minimum set of packages, elpy will install its own virt env for inline checking. While
# all other packages that might be needed by a script, should be installed in a dedicated virtual environment.
RUN python3 -m pip install ipython remote-pdb mypy pylint flake8 virtualenv
RUN ln -s /usr/bin/python3 /usr/bin/python

# add all GNU project public keys to prevent any issue with the installation of the emacs packages
RUN curl --verbose --output ~/_gnuring.gpg https://ftp.gnu.org/gnu/gnu-keyring.gpg \
    && gpg --import ~/_gnuring.gpg

# install hunspell, configure the locale to select a default dictionary
ENV LANG="en_US.UTF-8"
RUN apt update && apt install -y hunspell hunspell-en-us hunspell-it

# add a defualt ".emacs" file to the image home dir such that the hosted one is read from the store
COPY --chown=${UNAME}:${UNAME} .emacs ${EMACS_HOME}/

# add commands to the user path
WORKDIR ${EMACS_HOME}
ENV PATH="${EMACS_BIN}/bin:${EMACS_HOME}/.local/bin:$PATH"

RUN apt update && apt install -y \
    htop \
    git-lfs

# install and configure the GCM (Git Credential Manager) service
# NOTE: to complete the configuration it is required that the .gitconfig is prepared accordingly (use the
# emacs_git/linux/.gitconfig example as a start).
ARG GCM_INST_SCRIPT="install-from-source.sh"
RUN curl -LO \
    https://raw.githubusercontent.com/GitCredentialManager/git-credential-manager/main/src/linux/Packaging.Linux/${GCM_INST_SCRIPT}
RUN chmod u+x ${GCM_INST_SCRIPT} \
    && ./${GCM_INST_SCRIPT} -y \
    rm ${GCM_INST_SCRIPT}
RUN git-credential-manager-core configure && apt update && apt install -y pass

# uncomment all alias definitions in the bashrc
# NOTE: the "+" must be ecaped otherwise it is treated as a normal character
RUN \
    cp /etc/skel/.bashrc ${EMACS_HOME}/ \
    && sed -i 's/^#\s*alias\s\+l/alias l/' ${EMACS_HOME}/.bashrc \
    && sed -i "s/ll='ls/ll='ls -a/" ${EMACS_HOME}/.bashrc \
    && sed -i 's/^#\s*\(export\sLS_OPTIONS\)/\1/' ${EMACS_HOME}/.bashrc

# add to the sudoers group
RUN usermod -aG sudo ${UNAME}

USER ${UNAME}:${UNAME}
