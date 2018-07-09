#!/bin/bash
#

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
# Emulate a do...while loop to check for a login failure
# We want to continue attempting to login until success or another error code
while : ; do
    /steamcmd/steamcmd.sh \
        $STEAMCMD_VARIABLES \
        +login "$STEAM_LOGIN" \
        +force_install_dir /app \
        +app_update $APP_ID $VALIDATE \
        +quit
    retval=$?

    if [ "$retval" -eq 0 ] ; then
    # Break out of the loop and continue on if retval is 0
        touch "/$HOME/.logged_in_once"
        break
    elif [ "$retval" -ne 5 ] ; then
    # Exit the whole script if retval is not 5 (login error)
        exit $retval
    elif [ -f "/$HOME/.logged_in_once" ] ; then
    # We've managed to log in at once before,
    # So the problem probably isn't related to login information,
    # But rather a collision - multiple servers trying to login at once
    # Announce that you're looping and sleep for 30 +/- 5 seconds
    # The random time is to hopefully prevent collisions between login attempts
        sleep_time=$(( 25 + RANDOM % 11 ))
        echo "steamcmd login failed; waiting ${sleep_time}s and trying again."
        sleep "${sleep_time}s"
    else
    # Nothing to do here; retry the login immediately
        echo "steamcmd login failed; try again immediately."
    fi
done

# Handle the validation files
if [ "$VALIDATE_APP" = "once" ]; then
    touch /app/.validated || exit $?
elif [ "$VALIDATE_APP" = "never" ] && [ -f /app/.validate_once ]; then
    rm /app/.validate_once || exit $?
fi

# Run the thing!
$APP_EXEC || exit $?
