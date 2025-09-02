# ==================================================================================================
#
# Purpose     : Single image for spacemacs
#
# How To Build:
#
# $ cd <this folder>
# $ docker build --build-arg HOST_DOCKER_GID=<host-docker-gid> --build-arg GID=$(id -g) --build-arg UID=$(id -u) -t spacemacs:<tag> .
#
# Where GID and UID are required only if it is required that the default user in the docker image
# inherits the same rights as the user building the image.
#
# Sometimes the docker group number on the host differs from the GID in the image, also the host docker GID
# could be assigned to another group within the image. The "HOST_DOCKER_GID" variable allows to handle the
# situation at build time (see where it is used).
#
# To get the "docker" GID exec:
#     getent group docker
#
# For a list of supported distro check the beginning of the script.
# WARNING: when adding a new supported distro follow the steps below:
# - comment the major par of the script
# - generated uncommenting a chunk at the time
# - hence add if/else snippets to customize for the new distro
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

# IMPORTANT: need to be initialized otherwise they are not evaluated when invoking 'FROM'
ARG DISTRO_NAME=none
ARG DISTRO_VER=none
FROM ${DISTRO_NAME}:${DISTRO_VER}

# DANGER: anything above 'FROM' statement it won't be part of this build scope
# supported distros & versions
ARG DISTRO_NAME_UBUNTU="ubuntu"
ARG DISTRO_VER_UBUNTU="22.04"
ARG DISTRO_NAME_DEBIAN="debian"
ARG DISTRO_VER_DEBIAN="12"

# consume global scoped variables to access them in the stage scope (IMPORTANT: do not assign new values)
# source: https://docs.docker.com/build/building/variables/
ARG DISTRO_NAME
ARG DISTRO_VER

#==============================================================================================================
# DISTRO SPECIFIC SETTINGS
#==============================================================================================================
# ubuntu
# allow the installation and use of man-pages
RUN if [ "$DISTRO_NAME" = "$DISTRO_NAME_UBUNTU" ]; then yes | unminimize; fi

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
RUN --mount=type=secret,id=usr-password,env=USER_PASSWORD \
    echo "${UNAME}:${USER_PASSWORD}" | chpasswd && echo "root:${USER_PASSWORD}" | chpasswd
# add to the sudoers group
RUN usermod -aG sudo ${UNAME}
RUN usermod -aG dialout ${UNAME}
# disable annoying info about sudo on each new shell (source: https://askubuntu.com/a/22614)
RUN touch ${EMACS_HOME}/.sudo_as_admin_successful

#==============================================================================================================
# INSTALL EMACS
#==============================================================================================================

# prerequisites installation
# NOTE: the -lxft library supporting the "freetype" is not installed in favor of configuring Emacs with "Cairo"
# and "HarfBuzz".
# There seems to be a reason for the libxft not to be used (see
# /installs/emacs-29.4/emacs-sources/emacs-29.4/configure.ac:6930)
RUN apt-get update && apt-get install -y \
    curl \
    gpg \
    xz-utils \
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
    libwebp-dev \
    libgccjit-12-dev \
    libotf1 \
    libotf-dev \
    libfreetype6 \
    libfontconfig1 \
    libsqlite3-dev \
    libacl1-dev \
    xaw3dg-dev \
    libgpm-dev \
    libx11-xcb-dev \
    imagemagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# add all GNU project public keys to prevent any issue with the installation of the emacs packages
ARG GPG_KEYRING_PATH="${EMACS_HOME}/_gnuring.gpg"
RUN curl --verbose --output ${GPG_KEYRING_PATH} https://ftp.gnu.org/gnu/gnu-keyring.gpg \
    && gpg --import ${GPG_KEYRING_PATH}

ARG EMACS_INSTALLER_NAME="emacs-29.4"
ARG EMACS_INSTALLER_ARCH="${EMACS_INSTALLER_NAME}.tar.xz"
RUN mkdir /installs \
    && chown ${UNAME}:${UNAME} -R /installs
USER ${UNAME}
RUN mkdir -p /installs/${EMACS_INSTALLER_NAME} \
    && cd /installs/${EMACS_INSTALLER_NAME} \
    && curl --verbose --output ${EMACS_INSTALLER_ARCH} \
    https://ftp.gnu.org/pub/gnu/emacs/${EMACS_INSTALLER_ARCH} \
    && curl --verbose --output ${EMACS_INSTALLER_ARCH}.sig \
    https://ftp.gnu.org/pub/gnu/emacs/${EMACS_INSTALLER_ARCH}.sig \
    && gpgv --keyring ${GPG_KEYRING_PATH} ${EMACS_INSTALLER_ARCH}.sig ${EMACS_INSTALLER_ARCH} \
    && rm ${GPG_KEYRING_PATH}

ARG EMACS_SRC_DIR="emacs-sources"
RUN cd /installs/${EMACS_INSTALLER_NAME} \
    && mkdir ${EMACS_SRC_DIR} \
    && tar -vxf ${EMACS_INSTALLER_ARCH} -C ${EMACS_SRC_DIR} \
    && mkdir emacs-build

# no lisp native-compilation, does not seems to have a strong impact:
# https://www.reddit.com/r/emacs/comments/uv49ix/i_am_curious_how_many_of_you_are_using_native/ (enable anyway)
ARG EMACS_INSTALL_DIR=${EMACS_HOME}/emacsinstall
# FIXME: when enabling --native-compilation the install script reports:
#
# 7.570 checking for gcc_jit_context_acquire in -lgccjit... no
# 7.601 configure: error: ELisp native compiler was requested, but libgccjit was not found.
# 7.601 Please try installing libgccjit or a similar package.
# 7.601 If you are sure you want Emacs be compiled without ELisp native compiler,
# 7.601 pass the --without-native-compilation option to configure.
#
# Though the library is installed with 'libgccjit-12-dev'. Until the issue is resolved disable this feature.
#     --with-native-compilation \
RUN cd /installs/${EMACS_INSTALLER_NAME}/emacs-build \
    && ../${EMACS_SRC_DIR}/${EMACS_INSTALLER_NAME}/configure \
    --prefix=${EMACS_INSTALL_DIR} \
    --enable-profiling \
    --enable-checking \
    --with-wide-int \
    --with-x-toolkit=lucid \
    --with-imagemagick \
    --with-gconf \
    --with-sqlite3 \
    --with-imagemagick \
    --with-json \
    --without-mailutils \
    --without-pop \
    && make \
    && make install
# FIXME: the tree-sitter support in debian is still in testing (2024-11-17):  --with-tree-sitter
USER root

#==============================================================================================================
# ADDITIONAL PACKAGES
#==============================================================================================================
# lrzsz - tools for zmodem/xmodem/ymodem file transfer - installs sx, sb, sz commands
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
    lrzsz \
    strace \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# IMPORTANT: the icons used in Emacs are automatically installed via 'SPC SPC all-the-icons-install-fonts'
# (which requires a restart of the application to take effect).
# install fonts:
# - Source Code Pro (https://github.com/adobe-fonts/source-code-pro/tree/main?tab=readme-ov-file - last release)
# - Nanum Gothic
# - Segoe UI emoji (https://legionfonts.com/fonts/segoe-ui-emoji)
ARG SYSTEM_FONTS_DIR="/usr/share/fonts"
COPY support/*.zip ${SYSTEM_FONTS_DIR}
RUN cd ${SYSTEM_FONTS_DIR} \
    && for archive in $(ls *.zip); do unzip $archive; done \
    && fc-cache -f -v

# configure timezone (use US by default)
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
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

# handle docker group host/image issue
RUN usermod -aG docker ${UNAME}
ARG HOST_DOCKER_GID
ARG HOST_DOCKER_GNAME="dockerhostgroup"
RUN usermod -aG ${HOST_DOCKER_GID} ${UNAME} \
    || ( \
    groupadd --gid ${HOST_DOCKER_GID} ${HOST_DOCKER_GNAME} \
    && usermod -aG ${HOST_DOCKER_GID} ${UNAME} \
    )

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
    libxss-dev \
    libnss3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# manually install Firefox
ARG FIREFOX_SRC_PATH="/installs/firefox-src"
ARG FIREFOX_ARCHIVE="firefox-latest.tar.bz2"
RUN mkdir -p ${FIREFOX_SRC_PATH} \
    && cd ${FIREFOX_SRC_PATH} \
    && curl -fsSL -o ${FIREFOX_ARCHIVE} \
    "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" \
    && tar xvf ${FIREFOX_ARCHIVE} \
    && ln -s $PWD/firefox/firefox /usr/bin/firefox

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

# install direnv
RUN apt update && apt install -y direnv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    pipx \
    iproute2 \
    arp-scan \
    rsync \
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

# development packages
#   device-tree-compiler: dtc, fdtdump, etc..
#   u-boot-tools: mkimage, dumpimage
#   bc: dependency to build the linux kernel
RUN apt-get update && apt-get install -y \
    device-tree-compiler \
    u-boot-tools \
    bc \
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

# source extra configurations shared between docker and host shells (requires the definition of an OS variable
# pointing to a folder holding only strictly shareable scripts)
RUN echo '. $SHARED_SHELL_CFG/*' >> ${EMACS_BASHRC}

# install direnv hook (after it is overwritten by the skel)
RUN direnv hook bash >> ${EMACS_BASHRC}

# make sure the GPG agent works properly
RUN echo 'export GPG_TTY=$(tty)' >>${EMACS_BASHRC}

WORKDIR ${HHOME}
# allow locally installed binaries to be invoked
ENV PATH="${EMACS_HOME}/.local/bin:${EMACS_INSTALL_DIR}/bin:$PATH"
# use more colors than xterm when starting emacs in "-nw" mode
ENV TERM="xterm-256color"

USER ${UNAME}
