# ==============================================================================================================
# Purpose: build an environment suitable for statistical study
# ==============================================================================================================

FROM base:0.2

ARG UNAME=developer
ARG UNAME_ROOT=/home/${UNAME}

# install TA-lib
ARG TA_LIB="ta-lib"
ARG TA_LIB_ARCHIVE=${TA_LIB}.tar.gz

COPY --chown=root:root ./support/ta-lib*.tar.gz ${UNAME_ROOT}/${TA_LIB_ARCHIVE}
RUN \
    cd ${UNAME_ROOT} \
    && tar zxf ${TA_LIB_ARCHIVE} \
    && rm ${TA_LIB_ARCHIVE}
RUN \
    cd ${TA_LIB} && ./configure && make && make install
RUN cd ${UNAME_ROOT} && rm -rf ${TA_LIB}

# add custom scripts
COPY scripts/* /usr/local/bin/

# ps command
RUN apt update && apt install -y procps

USER ${UNAME}
