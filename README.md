# natethegreat68/steam-ded-server

## Docker container for Steam dedicated game servers

Flexible container for downloading/updating a Steam app using steamcmd and running a dedicated game server (one server per container).

## Information Needed for Configuration

### User and game information

steamcmd requires that games/servers be downloaded/updated by their numeric ID rather than game name, so finding this ID online is the first step.

After determining the game ID, you'll need to find whether the server can be downloaded anonymously or if it requires a Steam login. Again, the internet is your friend here.

The final piece of the puzzle here is finding out if any special variables/configs are needed. For example, Assetto Corsa (which is game/app #302550 and does require a login) requires that "sSteamCMDForcePlatformType" be set to "windows" for steamcmd. Settings like this are somewhat uncommon.

Jot all this information down somewhere for configuring the container in the following steps.

### Server port information

Although steamcmd itself doesn't need any inbound ports opened, the game server will (otherwise nobody will be able to reach it). Some servers allow the port number to be configured, while some are hard-coded. Regardless, you'll need to determine which ports are used, and whether they're TCP, UDP, or both - this information can usually be found online as ports that need to be set up in a router's port forwarding or NAT settings.

Write these down too, and go ahead and open these ports up on your router/firewall as well if you want the server to be accessible on the Internet rather than just inside your LAN. Configuring the router is outside the scope of this README.

## Volume Setup

The container expects two volumes:
* `/steam` steamcmd and its logs will reside here.
* `/app` The downloaded app and its configuration files will reside here.
Mounting shares for these volumes to use (for example, with Rancher-NFS or SMB) is beyond the scope of this README. A user, steam, and corresponding group will be made within the container to run steamcmd and the game server file. Its UID and GID are both 999 by default, but these can be customized with the `STEAM_UID` and `STEAM_GID` environment variables if necessary.

## Configuring with Rancher UI

If you're using Rancher UI for managing Docker containers (the default arrangement on FreeNAS 11.1), this section is the easiest way to get going. Otherwise, see "Running With Docker Command Line" below.

1. Select a Stack to add the Service to (or create a new Stack).
1. Click Add Service.
1. `Name` Give the Service a name. I recommend naming it after the game rather than just "Steam" so that running multiple servers for multiple games doesn't get confusing.
1. `Description` Add a description if desired.
1. `Select Image` "natethegreat68/steam-ded-server:latest"
1. `Port Map`: Enter the port information from the earlier section. Click the + button as many times as necessary. For each port enter:
    1. `Public Host Port` The port number.
    1. `Private Container Port` Also the port number.
    1. `Protocol` TCP or UDP. Ports that need both TCP *and* UDP opened will need two separate entries.
1. `Command` Tab:
    1. `Environment` Add an environment variable and value for each item below that you need:
        * `TZ` Enter the timezone information for accurate server time and logging. An example format is "America/New_York"
        * `APP_ID` The game ID number determined previously.
        * `STEAM_LOGIN` Optional; default is "anonymous". The username to use to login to steam.
        * `STEAMCMD_VARIABLES` Optional; any extra variables that need to be set. Separate them with spaces and write them as they would be used when running steamcmd from a shell, for example `+@sSteamCmdForcePlatformType windows`.
        * `STEAM_UID` Optional; default is 999. The UID for the steam user.
        * `STEAM_GID` Optional; defualt is 999. The GID for the steam user's group.
        * `VALIDATE_APP` Optional; default is "never". Choices are "never", "once", "always". Determines whether to run file validation after updating; this can sometimes overwrite configuration files, so use at your own risk.
        * `APP_EXEC` Optional; default is "/app/.app_exec". This can be the executable server file, a bash script, or anything else executable. `/app/.app_exec` will not exist by default, so it can be symlinked to the server executable or shell script (useful if you don't know the exact filepath to execute when setting up the container).
1. `Volumes` Tab:
    1. `Volumes` Add two volumes:
        * `<path to or name of steam volume>:/steam`
        * `<path to or name of app volume>:/app`
1. `Networking` Tab:
    1. `Network` Recommend setting to "Host"; I've found that some games won't connect to a LAN server if set to "Managed".
1. Click the "Create" button, wait for it to start up, and proceed to "Post-Configuration Setup and Maintenance". To easily get to a shell to complete the setup, the `Containers` Tab of the new Service page should have an "Execute Shell" option under `Actions`.

## Running With Docker Command Line

*to do*

## Post-Configuration Setup and Maintenance

### Getting to the shell (attaching to tmux)

steamcmd and the app are run in a tmux instance (session "steam") that belongs to the steam user, but the shell will login as the root user by default, so running `# su -c 'tmux attach' steam` (or the shortcut alias `# steam`) from the container's shell should get you in for maintenance.

To detach from the tmux session and leave it running, press keys Ctrl+b, then d.

### First-time login

If you specified a login username and this is your first login, you'll have to supply a password (and maybe also a Steam Guard token if requested). Simply attach to the tmux session as outlined above and follow the prompts.

### Actually running the game server

If you did not specify an app to exec with the `APP_EXEC` environment variable, you have three choices:
* Go back and alter the container's configuration so that `APP_EXEC` now specifies the file to execute.
* Make `/app/.app_exec` a symlink that points to the executable: `$ ln -s <path_to_executable> /app/.app_exec`.
* Make `/app/.app_exec` a shell script that eventually launches the server.

### Validation of games files

Validation of games files is handled by the value of the `VALIDATE_APP` environment variable and the presence of two files in the volume mounted on /app:
* If `VALIDATE_APP` is "always", then the app's files will be validated every time the container is run.
* If `VALIDATE_APP` is "once" and the file `/app/.validated` does not exist, the files will be validated the next time the container is run and the `/app/.validated` file will be created so they're not validated next time. Deleting the file manually will result in the files being validated on the next run.
* If `VALIDATE_APP` is "never" (the default choice) and the file `/app/.validate_once` exists, the files will be validated the next time the container is run and the `/app/.validate_once` file will be deleted so they aren't validated every time.
