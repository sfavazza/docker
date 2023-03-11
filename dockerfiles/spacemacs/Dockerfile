# ==============================================================================================================
# Custom build for doom-emacs
#
# To build ensure to indicate the tag of an existing Emacs docker image build
# ==============================================================================================================

# build with:
# docker build --build-arg EMACS_TAG=<tag>
ARG EMACS_TAG

FROM emacs_docker:${EMACS_TAG}

USER root

# remove default .emacs
ARG UNAME=emacsserver
ARG EMACS_HOME=/home/${UNAME}
RUN rm ${EMACS_HOME}/.emacs

USER ${UNAME}
