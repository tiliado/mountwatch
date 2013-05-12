#!/bin/sh
# This script is executed by removabled when "myexthdd" is about to be unmounted.
# The first argument is a full path of mount's root directory, e.g. "/media/myexthdd".

# This command unmounts encfs mount point with source directory on myexthdd.
fusermount -u ~/private/encfs-myexthdd
