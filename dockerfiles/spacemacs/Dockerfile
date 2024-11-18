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


ARG DISTRO_NAME="ubuntu"
ARG DISTRO_VER="22.04"
FROM ${DISTRO_NAME}:${DISTRO_VER}

# redefine as not visible when defined before the FROM instruction
ARG DISTRO_NAME="ubuntu"
ARG DISTRO_VER="22.04"

#==============================================================================================================
# DISTRO SPECIFIC SETTINGS
#==============================================================================================================
# ubuntu
# allow the installation and use of man-pages
RUN yes | unminimize

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

# user can choose a dedicated password
ARG USER_PASSWORD=${UNAME}

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
RUN echo "${UNAME}:${USER_PASSWORD}" | chpasswd && echo "root:root" | chpasswd
# add to the sudoers group
RUN usermod -aG sudo ${UNAME}
RUN usermod -aG dialout ${UNAME}
# disable annoying info about sudo on each new shell (source: https://askubuntu.com/a/22614)
RUN touch ${EMACS_HOME}/.sudo_as_admin_successful

#==============================================================================================================
# INSTALL EMACS
#==============================================================================================================

# # install emacs 29 from backport, (source https://backports.debian.org/Instructions/)
# ARG DEBIAN_VER_NAME=bookworm
# RUN echo 'deb http://deb.debian.org/debian bookworm-backports main' > /etc/apt/sources.list.d/backports.list
# RUN apt-get update && apt-get install -y \
#     emacs-el/${DEBIAN_VER_NAME}-backports \
#     emacs-lucid/${DEBIAN_VER_NAME}-backports \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    gpg \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# add all GNU project public keys to prevent any issue with the installation of the emacs packages
RUN curl --verbose --output ~/_gnuring.gpg https://ftp.gnu.org/gnu/gnu-keyring.gpg \
    && gpg --import ~/_gnuring.gpg

ARG EMACS_INSTALLER_NAME="emacs-29.4"
ARG EMACS_INSTALLER_ARCH="${EMACS_INSTALLER_NAME}.tar.xz"
RUN mkdir /opt/${EMACS_INSTALLER_NAME} \
    && cd /opt/${EMACS_INSTALLER_NAME} \
    && curl --verbose --output ${EMACS_INSTALLER_ARCH} \
    https://ftp.gnu.org/pub/gnu/emacs/${EMACS_INSTALLER_ARCH} \
    && curl --verbose --output ${EMACS_INSTALLER_ARCH}.sig \
    https://ftp.gnu.org/pub/gnu/emacs/${EMACS_INSTALLER_ARCH}.sig \
    && gpgv --keyring ~/*.gpg ${EMACS_INSTALLER_ARCH}.sig ${EMACS_INSTALLER_ARCH}

ARG EMACS_SRC_DIR="emacs-sources"
RUN cd /opt/${EMACS_INSTALLER_NAME} \
    && mkdir ${EMACS_SRC_DIR} \
    && tar -vxf ${EMACS_INSTALLER_ARCH} -C ${EMACS_SRC_DIR} \
    && mkdir emacs-build #
    # && cd emacs-build \
    # ../${EMACS_SRC_DIR}/configure

# installation prerequisites
RUN apt-get update && apt-get install -y \
    build-essential \
    texinfo \
    pkg-config \
    libgnutls28-dev \
    libsystemd-dev \
    libjansson-dev \
    liblcms2-dev \
    libtinfo-dev \
    libxaw7-dev \
    xaw3dg-dev \
    libtiff5-dev \
    libgif-dev \
    libharfbuzz-dev \
    libmagick++-dev \
    libsqlite3-dev \
    libwebp-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# no lisp native-compilation, does not seems to have a strong impact: https://www.reddit.com/r/emacs/comments/uv49ix/i_am_curious_how_many_of_you_are_using_native/
RUN cd /opt/${EMACS_INSTALLER_NAME}/emacs-build \
    && ../${EMACS_SRC_DIR}/${EMACS_INSTALLER_NAME}/configure \
    --enable-profiling \
    --enable-checking \
    --with-x-toolkit=lucid \
    --with-imagemagick \
    --with-sqlite3 \
    --without-mailutils \
    --without-pop \
    && make \
    && make install

#==============================================================================================================
# ADDITIONAL PACKAGES
#==============================================================================================================
RUN apt-get update && apt-get install -y \
    apt-utils \
    git \
    file \
    tree \
    man \
    bash-completion \
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
    screen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# configure timezone (use US by default)
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN apt update \
    && apt install -y locales \
    && sed -i "s/^#\s*en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV TZ=Etc/UTC
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# python
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    python-is-python3 \
    python3-ipython \
    python3-virtualenv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# add docker (source: https://docs.docker.com/engine/install/debian/#install-using-the-repository)
RUN apt update && apt install -y \
    ca-certificates \
    lsb-release \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/${DISTRO_NAME}/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${DISTRO_NAME} \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update

RUN apt update && apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# docker group handling
# WARNING: some group IDs are different among distros. As a work around add the main user of the image to the
# corresponding "docker" group IDs as detected in the image itself (unfortunately this makes the build split in
# 2 phases). The following comments show how the "docker" group on a host with <distro> is represented in the
# this image:
# - <distro> <release>: <group-on-host>
    # FIXME: a more radical solution would consist in selecting the starting image based on the distribution on
    # the host building the image
# - debian bullseye: systemd-network
# RUN usermod -aG systemd-network ${UNAME}
# - ubuntu jammy: systemd-journal
# RUN usermod -aG systemd-journal ${UNAME}
# - same as host
RUN usermod -aG docker ${UNAME}

# install hunspell, configure the locale to select a default dictionary
ENV LANG="en_US.UTF-8"
RUN apt update && apt install -y \
    hunspell \
    hunspell-en-us \
    hunspell-it \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# add tools for terminal layer
RUN apt update && apt install -y \
    libtool-bin \
    libvterm-dev \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# tools to render and preview markdown files
RUN apt update && apt install -y \
    pandoc \
    firefox \
    libxss-dev \
    libnss3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
# github flavored markdown renderer (application & dependencies)
RUN apt-get update && apt-get install -y \
    libgtk-3-0 \
    libx11-xcb1 \
    libasound2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g vmd
# install language server(s)
RUN npm install -g dockerfile-language-server-nodejs

# LSP support for bash scripts
RUN npm install -g bash-language-server

# C/C++ support
RUN apt update && apt install -y \
    clangd \
    bear \
    cscope \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install direnv and hook the shell
RUN apt update && apt install -y direnv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install Nerd and NanumGothic fonts
COPY --chown=${UNAME}:${UNAME} support/*.zip ${EMACS_HOME}/.fonts/
RUN cd ${EMACS_HOME}/.fonts \
    && for archive in $(ls *.zip); do unzip $archive; done \
    && fc-cache -fv

WORKDIR ${HHOME}
ENV PATH="${HHOME}/.local/bin:$PATH"

RUN apt-get update && apt-get install -y \
    iproute2 \
    arp-scan \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# manipulate JSON data & debug other-archs
RUN apt-get update && apt-get install -y \
    jq \
    gdb-multiarch \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# emacs doc-view dependencies (check with 'SPC SPC find-library doc-view', hence read the input)
RUN apt-get update && apt-get install -y \
    xpdf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# WARNING: not the best idea to install random cross compiler, each system should provide the recommended
# tool-chains.
# # cross-compiler tool-chains
# RUN apt-get update && apt-get install -y \
#     binutils-arm-linux-gnueabi \
#     binutils-arm-linux-gnueabihf \
#     gcc-arm-linux-gnueabi \
#     gcc-arm-linux-gnueabihf

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

# make sure the GPG agent works properly
RUN echo 'export GPG_TTY=$(tty)' >>${EMACS_HOME}/.bashrc

USER ${UNAME}
