FROM ubuntu:17.10

# Define some default values for the ENV variables
ENV TZ="UTC" \
    APP_ID=0 \
    STEAM_LOGIN="anonymous" \
    STEAMCMD_VARIABLES="" \
    STEAM_UID=999 \
    STEAM_GID=999 \
    VALIDATE_APP="never" \
    APP_EXEC="/app/.app_exec" \
    SESSION_NAME="steam" \
    TERM=xterm

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        tmux \
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
# /steamcmd directory: create, download steamcmd, and set perms
WORKDIR /steamcmd
ADD http://media.steampowered.com/client/steamcmd_linux.tar.gz ./
RUN tar -xzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz
RUN chown -R steam:steam . && \
    chmod -R 775 .
# /steam directory: create and set perms
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

# Run the main command
CMD /scripts/run.sh
