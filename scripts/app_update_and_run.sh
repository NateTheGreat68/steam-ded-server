#!/bin/bash
#

# Exit when any command fails
set -e

ls -Rl /steam

# Validate the app's files?
if [ "$VALIDATE_APP" = "always" ]; then 
    VALIDATE="validate"
elif [ "$VALIDATE_APP" = "once" ] && [ ! -f /app/.validated ]; then
    VALIDATE="validate"
elif [ "$VALIDATE_APP" = "never" ] && [ -f /app/.validate_once ]; then
    VALIDATE="validate"
else
    VALIDATE=""
fi

# Update the app by building up a steamcmd command
/steam/steamcmd/steamcmd.sh \
    $STEAMCMD_VARIABLES \
    +login "$STEAM_LOGIN" \
    +force_install_dir /app \
    +app_update $APP_ID $VALIDATE \
    +quit

# Handle the validation files
if [ "$VALIDATE_APP" = "once" ]; then
    touch /app/.validated
elif [ "$VALIDATE_APP" = "never" ] && [ -f /app/.validate_once ]; then
    rm /app/.validate_once
fi

# Run the thing!
$APP_EXEC
