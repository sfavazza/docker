# ==================================================================================================
#
# File        : Dockerfile
#
# Purpose     : Recipe for a working free ModelSIM Altera FPGA edition.
#
# Author(s)   : Samuele FAVAZZA (samuele.favazza@duagon.com)
# 
# =================================================================================================

FROM base:latest

# copy the install file to the file-system of the container
ARG JOB_WORK_DIR=/home/developer/work
COPY --chown=root:root support/ModelSimSetup-20.1.1.720-linux.run ${JOB_WORK_DIR}

# install the dependencies (use 32-bit version)
RUN dpkg --add-architecture i386 && apt update \
	&& apt install -y unixodbc:i386 unixodbc-dev:i386 libncurses5 libncurses5:i386 libzmq3-dev:i386 \
	&& libxext6:i386 libxtst6:i386 libxft2:i386 libxml2:i386 libedit2:i386 libx11-6:i386 libxi6:i386

# execute the installation script in unattended mode
# RUN bash -c './ModelSimSetup-20.1.1.720-linux.run --unattendedmodeui minimalWithDialogs --mode unattended --accept_eula 1'
