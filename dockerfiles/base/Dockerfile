# ==============================================================================================================
# Purpose     : Build a basic image with user/root setup and all usual development tools
# ==============================================================================================================

FROM debian:bullseye

# Local variables used at build time (WARNING: the "ARG" def are available only at the building stage, they must
# be re-defined as required in child images).
ARG UNAME=developer
ARG UNAME_ROOT=/home/${UNAME}

# add a new user and change the root password
RUN adduser --disabled-login --gecos "Simply a developer,,," ${UNAME}; \
	echo "${UNAME}:${UNAME}" | chpasswd; \
	echo "root:root" | chpasswd

# install tools ###############################################################
RUN apt update \
	&& apt install -y apt-utils git make file tree man nano bash-completion build-essential

# enable bash completion
RUN chmod u+x /etc/profile.d/bash_completion.sh && . /etc/profile.d/bash_completion.sh

# python 3.9 is included, install pip and install support packges for elpy
RUN apt update \
    && apt install -y python3-pip python3-venv \
    && python3 -m pip install --upgrade pip
RUN python3 -m pip install mypy pylint flake8 ipython remote-pdb pre-commit
RUN ln -s /usr/bin/python3 /usr/bin/python

# uncomment all alias definitions in the bashrc
# NOTE: the "+" must be ecaped otherwise it is treated as a normal character
RUN \
    cp /etc/skel/.bashrc ${UNAME_ROOT}/ \
    && sed -i 's/^#\s*alias\s\+l/alias l/' ${UNAME_ROOT}/.bashrc \
    && sed -i "s/ll='ls/ll='ls -a/" ${UNAME_ROOT}/.bashrc \
    && sed -i 's/^#\s*\(export\sLS_OPTIONS\)/\1/' ${UNAME_ROOT}/.bashrc

# NOTE: always set the developer user as starting working folder, but do not set the user unless for a job image
WORKDIR ${UNAME_ROOT}

# reconfigure "dash" such that "sh" invokes "bash"
RUN echo "dash dash/sh boolean false" | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

ENV PATH="${UNAME_ROOT}/.local/bin:$PATH"

# --------------------------------------------------------------------------------------------------------------
# deprecated
# setup miniconda ###############################################
# ARG CONDA_DIR=/home/${UNAME}/programs/conda
# COPY --chown=root:root support/Miniconda3-latest-Linux-x86_64.sh /opt/conda_install.sh
# RUN cd /opt && \
# 	chmod 744 conda_install.sh && \
# 	./conda_install.sh -b -p ${CONDA_DIR}

# add commands to the user path
# ENV PATH="${CONDA_DIR}/bin:$PATH"

# initialize the shell to use conda environments
# RUN conda init bash
