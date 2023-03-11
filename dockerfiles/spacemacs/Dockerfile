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

# remove default .emacs
ARG UNAME=emacsserver
ARG EMACS_HOME=/home/${UNAME}
RUN rm ${EMACS_HOME}/.emacs

USER ${UNAME}
