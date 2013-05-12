#!/bin/sh
# This script is executed by Mount Watch when "myexthdd" is mounted.
# The first argument is a full path of mount's root directory, e.g. "/media/myexthdd".

# Run unison synchronization tool to sync my work stuff.
unison-gtk myexthdd-work-stuff &
