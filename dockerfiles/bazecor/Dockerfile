# image for bazecor development
# image name: bazecor-dev:<tag>

FROM base:bookworm

ARG UNAME=developer
ARG UNAME_HOME=/home/${UNAME}
ARG NODEJS_VER_MAJ=20

RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install nodejs
# source: https://deb.nodesource.com/
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODEJS_VER_MAJ}.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install nodejs -y

# install yarn
RUN corepack enable

# install dependencies
RUN apt-get update && apt-get install -y \
    libudev-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER ${UNAME}
