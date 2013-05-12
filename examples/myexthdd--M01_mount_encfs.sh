#!/bin/sh
# This script is executed by Mount Watch when "myexthdd" is mounted.
# The first argument is a full path of mount's root directory, e.g. "/media/myexthdd".

# This command mounts encfs directory using gnome-encfs.
gnome-encfs --mount "$1/encrypted"
