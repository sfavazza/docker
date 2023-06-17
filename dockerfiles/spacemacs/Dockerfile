# ==============================================================================================================
# Custom build for doom-emacs
#
# To build ensure to indicate the tag of an existing Emacs docker image build
# ==============================================================================================================

# INSTRUCTIONS:
#
# Building
# docker build --build-arg EMACS_TAG=<tag> -t spacemacs:<tag> .

# First setup
# create the following structure:
# - <spacemacs-folder>/
#   - .emacs.d/ (empty-dir)
#   - .spacemacs (auto-generated or your file)
ARG EMACS_TAG

FROM emacs_docker:${EMACS_TAG}

USER root

RUN apt update && apt install -y \
    ripgrep \
    zip

ARG UNAME=emacsserver
ARG EMACS_HOME=/home/${UNAME}

# remove default .emacs
RUN rm ${EMACS_HOME}/.emacs

# provided that the 'org' layer is enabled, this has a conflict with the emacs shipped version of org-mode.
# Hence move the legacy 'org' package such that emacs cannot find it.
RUN cd ${EMACS_HOME}/emacs_install/share/emacs/*/lisp/ \
    && mv org _back.org

# add tools for terminal layer
RUN apt update && apt install -y \
    libtool-bin \
    libvterm-dev \
    cmake

# add other tools
RUN apt update && apt install -y \
    screen

# tools to render and preview markdown files
RUN apt update && apt install -y \
    pandoc \
    firefox-esr \
    libxss-dev \
    libnss3

# manually install nodejs and npm (package manager holds an old version)
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash - && apt-get install -y nodejs

# github flavored markdown renderer
RUN npm install -g vmd

# install language server(s)
RUN npm install -g dockerfile-language-server-nodejs

# install clangd and bear (for compilation commands)
RUN apt update && apt install -y \
    clangd-11 \
    bear \
    && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-11 100

# LSP support for bash scripts
RUN npm install -g bash-language-server

RUN usermod -aG dialout ${UNAME}

RUN apt update && apt install -y \
    direnv

USER ${UNAME}

# install Nerd and NanumGothic fonts
COPY --chown=${UNAME}:${UNAME} support/*.zip ${EMACS_HOME}/.fonts/
RUN cd ${EMACS_HOME}/.fonts \
    && for archive in $(ls *.zip); do unzip $archive; done \
    && fc-cache -fv
