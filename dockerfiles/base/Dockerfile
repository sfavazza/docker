# ==================================================================================================
#
# File        : base_df
#
# Purpose     : Build a basic image with user/root setup and a conda installation
#
# Author(s)   : Samuele FAVAZZA (sfavazza.github@gmail.com)
# 
# =================================================================================================

FROM debian:bullseye

# local variables used at build time
ARG UNAME=developer
ARG CONDA_DIR=/home/${UNAME}/programs/conda
ARG JOB_WORK_DIR=/home/${UNAME}/work

# add a new user and change the root password
RUN adduser --disabled-login --gecos "Simply a developer,,," ${UNAME}; \
	echo "${UNAME}:${UNAME}" | chpasswd; \
	echo "root:root" | chpasswd

# NOTE: always set the developer user as starting working folder, but do not set the user unless for a job image
WORKDIR $JOB_WORK_DIR

# install tools ###############################################################
RUN apt update \
	&& apt install -y git make file tree man nano

# setup miniconda ###############################################
COPY --chown=root:root support/Miniconda3-latest-Linux-x86_64.sh /opt/conda_install.sh
RUN cd /opt; \
	chmod 744 conda_install.sh; \
	./conda_install.sh -b -p ${CONDA_DIR};

# add commands to the user path
ENV PATH="${CONDA_DIR}/bin:$PATH"

# initialize the shell to use conda environments
RUN conda init bash

# uncomment all alias definitions in the bashrc
RUN sed -i 's/^#\s*alias\s\+l/alias l/' /root/.bashrc
RUN sed -i 's/^#\s*\(export\sLS_OPTIONS\)/\1/' /root/.bashrc
