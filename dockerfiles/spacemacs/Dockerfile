# ==================================================================================================
#
# Purpose     : Single image for spacemacs
#
# How To Build:
#
# $ cd <this folder>
# $ docker build --build-arg GID=$(id -g) --build-arg UID=$(id -u) -t spacemacs:<tag> .
#
# Where GID and UID are required only if it is required that the default user in the docker image
# inherits the same rights as the user building the image.
#
# How To Use It
#
# Create two new commands in your OS, one to invoke the emacs-daemon in the docker, the other one to invoke an
# emacsclient (both in background to not open too many terminals). Create the following structure:
# - store
#   |- .precommit_cache: folder where pre-commit initialize its environment (faster over multiple emacs server
#   |  invocations)
#   |- emacs_git: org-based configuration
#   `- configs: folder containing optional tool configurations files (e.g. .gitconfig, .ssh (folder), etc..)
#
# Checkout the spacemacs repository in a folder ".emacs.d" and map it to $HOME/.emacs.d in the container.
#
# The files found in "configs" shall be mapped in under the home directory in the docker image.
#
# The display address should be the one of the machine hosting a X11-server. The value after the colon is the
# display number, when '0' the default display is used.
#
# Some usual shortcuts to start the Emacs server can be found in the "custom_bashrc.sh" script in the emacs_git
# repo. Configure it according to your needs by assigning the variable inspected at the beginning of the script.
#
# --------------------------------------------------------------------------------------------------------------
#
#
# Author(s)   : Samuele FAVAZZA (sfavazza.github@gmail.com)
#
# =================================================================================================


# debian 12
ARG DEBIAN_VER_NAME=bookworm
FROM debian:${DEBIAN_VER_NAME}

#==============================================================================================================
# PRELIMINARY DEFINITIONS
#==============================================================================================================

# Default group and user IDs, to build the container having the same rights of the user building it. Provide the
# desired values via the docker-build command.
ARG GID=1000
ARG UID=1000

# local variables used at build time
ARG UNAME=esrv
ARG EMACS_HOME=/home/${UNAME}
ARG EMACS_BUILD=${EMACS_HOME}/emacs_build
ARG EMACS_ARCHIVE=emacs.tar.gz
ARG EMACS_BIN=${EMACS_HOME}/emacs_install
ARG EMACS_BASHRC=${EMACS_HOME}/.bashrc
ARG HHOME=/home/sfavazza

#==============================================================================================================
# HANDLE USERS AND GROUPS
#==============================================================================================================
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
# add to the sudoers group
RUN usermod -aG sudo ${UNAME}
RUN usermod -aG dialout ${UNAME}

#==============================================================================================================
# INSTALL EMACS
#==============================================================================================================

# install emacs 29 from backport, (source https://backports.debian.org/Instructions/)
ARG DEBIAN_VER_NAME=bookworm
RUN echo 'deb http://deb.debian.org/debian bookworm-backports main' > /etc/apt/sources.list.d/backports.list
RUN apt-get update && apt-get install -y \
    emacs-el/${DEBIAN_VER_NAME}-backports \
    emacs-lucid/${DEBIAN_VER_NAME}-backports

#==============================================================================================================
# ADDITIONAL PACKAGES
#==============================================================================================================
RUN apt-get update && apt-get install -y \
    apt-utils \
    git \
    make \
    file tree man \
    bash-completion \
    build-essential \
    sudo \
    htop \
    git-lfs \
    gdb \
    ripgrep \
    zip \
    gnupg \
    shellcheck \
    iputils-ping \
    graphviz \
    screen

# python
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    python-is-python3 \
    python3-ipython \
    python3-virtualenv

# add docker (source: https://docs.docker.com/engine/install/debian/#install-using-the-repository)
RUN apt update && apt install -y \
    ca-certificates \
    lsb-release \
    curl
RUN mkdir -m 0755 -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt update && apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# install hunspell, configure the locale to select a default dictionary
ENV LANG="en_US.UTF-8"
RUN apt update && apt install -y \
    hunspell \
    hunspell-en-us \
    hunspell-it

# add tools for terminal layer
RUN apt update && apt install -y \
    libtool-bin \
    libvterm-dev \
    cmake

# tools to render and preview markdown files
RUN apt update && apt install -y \
    pandoc \
    firefox-esr \
    libxss-dev \
    libnss3

#==============================================================================================================
# NPM
#==============================================================================================================
# source: https://deb.nodesource.com/
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=20 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install nodejs -y
# github flavored markdown renderer
RUN npm install -g vmd
# install language server(s)
RUN npm install -g dockerfile-language-server-nodejs

# LSP support for bash scripts
RUN npm install -g bash-language-server

# C/C++ support
RUN apt update && apt install -y \
    clangd \
    bear \
    cscope

# install direnv and hook the shell
RUN apt update && apt install -y direnv

# add all GNU project public keys to prevent any issue with the installation of the emacs packages
RUN curl --verbose --output ~/_gnuring.gpg https://ftp.gnu.org/gnu/gnu-keyring.gpg \
    && gpg --import ~/_gnuring.gpg

# configure timezone (use US by default)
RUN apt update \
    && apt install -y locales \
    && sed -i "s/^#\s*en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
    && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install Nerd and NanumGothic fonts
COPY --chown=${UNAME}:${UNAME} support/*.zip ${EMACS_HOME}/.fonts/
RUN cd ${EMACS_HOME}/.fonts \
    && for archive in $(ls *.zip); do unzip $archive; done \
    && fc-cache -fv

# WARNING: some group IDs are different between "bookworm" and "bullseye". In particular "docker" group on
# "bullseye" has the value of "systemd-network" on "bookworm".
RUN usermod -aG systemd-network ${UNAME}

WORKDIR ${HHOME}
ENV PATH="${HHOME}/.local/bin:$PATH"

#==============================================================================================================
# customize shell configuration
#==============================================================================================================
# uncomment all alias definitions in the bashrc
# NOTE: the "+" must be ecaped otherwise it is treated as a normal character
RUN \
    cp /etc/skel/.bashrc ${EMACS_HOME}/ \
    && sed -i 's/^#\s*alias\s\+l/alias l/' ${EMACS_BASHRC} \
    && sed -i "s/ll='ls/ll='ls -a/" ${EMACS_BASHRC} \
    && sed -i 's/^#\s*\(export\sLS_OPTIONS\)/\1/' ${EMACS_BASHRC}

# install direnv hook (after it is overwritten by the skel)
RUN direnv hook bash >> ${EMACS_HOME}/.bashrc

RUN apt-get update && apt-get install -y \
    iproute2 \
    arp-scan

USER ${UNAME}
