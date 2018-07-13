#!/bin/bash
#

# Exit if anything fails
set -e

# Set the environment variables
# If they begin with a slash (that is, if they're absolute paths), don't prepend
if [ "${APP_DIR::1}" != "/" ]; then
    export APP_DIR="/app/$APP_DIR"
fi
if [ "${APP_EXEC::1}" != "/" ]; then
    export APP_EXEC="$APP_DIR/$APP_EXEC"
fi

# Make the folder if necessary
mkdir -p "$APP_DIR"

# Fix the permissions
usermod -u $STEAM_UID steam
groupmod -g $STEAM_GID steam
usermod -g $STEAM_GID steam
chown -R steam:steam \
    /steamcmd \
    /steam \
    /app

# Run the main command, as user steam, inside tmux
su -c "/usr/bin/script -qc '/usr/bin/tmux new -s steam /scripts/app_update_and_run.sh' /dev/null" steam
