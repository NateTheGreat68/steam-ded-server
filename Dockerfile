FROM ubuntu:17.10

# Get and setup S6-Overlay
ADD https://github.com/just-containers/s6-overlay-builder/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

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

# Copy files
COPY root/ /

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        wget \
        tmux \
        lib32stdc++6

# Setup user and group
RUN groupadd -g $STEAM_GID steam && \
    useradd -Md /steam -Ng $STEAM_GID -s /bin/bash \
        -u $STEAM_UID --no-log-init steam

# Set up directories
WORKDIR /steam
RUN chown steam:steam /steam
RUN chmod 775 /steam
WORKDIR /app
RUN chown steam:steam /steam
RUN chmod 775 /steam

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
    CMD /healthcheck.sh || exit 1

# Switching user
USER steam

# Installation script
RUN /install_steamcmd.sh

# Set the entrypoint for S6-Overlay
ENTRYPOINT ["/init"]
