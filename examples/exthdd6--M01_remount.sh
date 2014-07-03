#!/bin/sh
# remount btrfs partition

set -eu
path="$1"
name="$2"

mount -o remount,rw,noatime,compress=lzo,space_cache,inode_cache,nosuid,nodev,uhelper=udisks2 "$path"
