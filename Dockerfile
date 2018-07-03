FROM ubuntu:17.10

# Define some default values for the ENV variables
ENV TZ "UTC" # should be set at runtime
ENV APP_ID 0 # should be set at runtime
ENV STEAM_LOGIN "anonymous"
ENV STEAMCMD_VARIABLES ""
ENV STEAM_UID 999
ENV STEAM_GID 999
ENV VALIDATE_APP "never"
ENV APP_EXEC "/app/.app_exec"
ENV SESSION_NAME "steam"

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        lib32stdc++6 \
        ca-certificates

# Setup user and group
RUN groupadd -g $STEAM_GID steam && \
    useradd -Md /steam -Ng $STEAM_GID -s /bin/bash \
        -u $STEAM_UID --no-log-init steam

# Set up directories
# /scripts directory: copy from contex and set perms
COPY scripts/ /scripts/
WORKDIR /scripts
RUN chown -R root:root . && \
    chmod -R uga+x .
# /steam directory: create, download steamcmd, and set permis
WORKDIR /steam/steamcmd
ADD http://media.steampowered.com/client/steamcmd_linux.tar.gz ./
RUN tar -xzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz
WORKDIR /steam
RUN chown -R steam:steam . && \
    chmod -R 775 .
# /app directory: create and set perms
WORKDIR /app
RUN chown -R steam:steam . && \
    chmod -R 775 .

# Define the volumes
VOLUME /app /steam

# Remove unnecessary packages and stuff
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Define the Docker healthcheck
HEALTHCHECK --interval=200s --timeout=100s \
    CMD /scripts/healthcheck.sh || exit 1

# Switching user
USER steam

# Run the main command
CMD /scripts/app_update_and_run.sh
