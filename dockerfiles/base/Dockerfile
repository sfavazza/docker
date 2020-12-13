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

# install conda package manager ###############################################
COPY --chown=root:root setup_support/Miniconda3-latest-Linux-x86_64.sh /opt/conda_install.sh
RUN cd /opt; \
	chmod 744 conda_install.sh; \
	./conda_install.sh -b -p ${CONDA_DIR};

# add commands to the user path
ENV PATH="${CONDA_DIR}/bin:$PATH"

# create a 32bit environment
# RUN set CONDA_FORCE_32BIT=1; \
# 	conda create -y --name py3x7_32b;

USER developer
