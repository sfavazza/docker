# ==============================================================================================================
# Custom build for doom-emacs
#
# To build ensure to indicate the tag of an existing Emacs docker image build
# ==============================================================================================================

# INSTRUCTIONS:
#
# Building
# docker build --build-arg EMACS_TAG=<tag>

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

USER ${UNAME}

# install Nerd and NanumGothic fonts
COPY --chown=${UNAME}:${UNAME} support/*.zip ${EMACS_HOME}/.fonts/
RUN cd ${EMACS_HOME}/.fonts \
    && for archive in $(ls *.zip); do unzip $archive; done \
    && fc-cache -fv