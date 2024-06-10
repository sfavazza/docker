# Purpose: Build a basic image with user/root setup and all usual development tools
# build: docker build -t base:<DEBIAN_VER_NAME>

ARG DEBIAN_VER_NAME
FROM debian:${DEBIAN_VER_NAME}

# Local variables used at build time (WARNING: the "ARG" def are available only at the building stage, they must
# be re-defined as required in child images).
ARG UNAME=developer
ARG UNAME_HOME=/home/${UNAME}
# Default group and user IDs, to build the container having the same rights of the user building it. Provide the
# desired values via the docker-build command.
ARG GID=1000
ARG UID=1000

# add the user group
RUN groupadd --gid ${GID} ${UNAME}
# add a new user and change the root password
RUN useradd \
    -d ${UNAME_HOME} --create-home \
# this option is important to prevent the command from creating huge files (which make the docker builder
# hang) when the GID/UID values are big.
    --no-log-init \
    --gid ${GID} --uid ${UID} \
    --skel /etc/skel --shell /bin/bash \
    ${UNAME}
RUN echo "${UNAME}:${UNAME}" | chpasswd && echo "root:root" | chpasswd
# add to the sudoers group
RUN usermod -aG sudo ${UNAME}

# install tools ###############################################################
RUN apt update \
	  && apt install -y \
    apt-utils git make file tree man nano bash-completion build-essential sudo

# enable bash completion
RUN chmod u+x /etc/profile.d/bash_completion.sh && . /etc/profile.d/bash_completion.sh

# install python
RUN apt-get update && apt-get install -y \
    python3-pip python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python

# uncomment all alias definitions in the bashrc
# NOTE: the "+" must be ecaped otherwise it is treated as a normal character
RUN \
    cp /etc/skel/.bashrc ${UNAME_HOME}/ \
    && sed -i 's/^#\s*alias\s\+l/alias l/' ${UNAME_HOME}/.bashrc \
    && sed -i "s/ll='ls/ll='ls -a/" ${UNAME_HOME}/.bashrc \
    && sed -i 's/^#\s*\(export\sLS_OPTIONS\)/\1/' ${UNAME_HOME}/.bashrc

# NOTE: always set the developer user as starting working folder, but do not set the user unless for a job image
WORKDIR ${UNAME_HOME}

# Reconfigure "dash" such that "sh" invokes "bash". Source:
# https://superuser.com/questions/715722/how-to-do-dpkg-reconfigure-dash-as-bash-automatically#comment915691_715790
RUN echo "dash dash/sh boolean false" | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# configure timezone (use US by default)
RUN apt update \
    && apt install -y locales \
    && sed -i "s/^#\s*en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
    && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV PATH="${UNAME_HOME}/.local/bin:$PATH"

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
