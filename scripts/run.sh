#!/bin/bash
#

# Exit if anything fails
set -e

# Fix the permissions
/scripts/fix_perms.sh

# Run the main command, as user steam, inside tmux
su -c "/usr/bin/script -qc '/usr/bin/tmux new -s steam /scripts/app_update_and_run.sh' /dev/null" steam
