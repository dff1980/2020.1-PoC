#!/usr/bin/env bash

while grep "rbd" /proc/mounts > /dev/null 2>&1; do
  for dev in $(lsblk -p -o NAME | grep "rbd"); do
    if $(mountpoint -x $dev > /dev/null 2>&1); then
      echo ">>> umounting $dev"
      umount -vAf "$dev"
    fi
  done
done