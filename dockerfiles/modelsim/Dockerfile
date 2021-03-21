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

# execute the installation script in unattended mode
RUN bash -c './ModelSimSetup-20.1.1.720-linux.run --unattendedmodeui minimalWithDialogs --mode unattended --accept_eula 1'
