#!/bin/bash
#

usermod -u $STEAM_UID steam
groupmod -g $STEAM_GID steam
usermod -g $STEAM_GID steam

chown -R steam:steam \
    /steamcmd \
    /steam \
    /app
