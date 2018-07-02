#!/bin/bash
#

# Exit when any command fails
set -e

# Make the directory
mkdir -p /steam/steamcmd

# Get and extract, then delete the official steamcmd tarball
wget -P /tmp http://media.steampowered.com/client/steamcmd_linux.tar.gz
tar -xzf /tmp/steamcmd_linux.tar.gz -C /steam/steamcmd
rm /tmp/steamcmd_linux.tar.gz
