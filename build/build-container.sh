#!/usr/bin/env bash
set -xeuo pipefail

export _BUILD_CONTAINER=1
source /etc/profile.d/symbian-env.sh

cd /var/tmp

declare -a EROFS_ARGS
EROFS_ARGS=(-zlz4)

export DEBIAN_FRONTEND="noninteractive"

dpkg --add-architecture i386

apt-get update

apt-get install --no-install-recommends -y \
  binfmt-support wine wine32:i386 wine-binfmt python3 ninja-build cmake build-essential erofsfuse \
  perl

declare -a APT_MARK
APT_MARK=()
apt-mark showmanual |readarray -t APT_MARK

_cleanup_apt () {
  (( ${#APT_MARK[@]} )) \
    && apt-mark auto '.*' >/dev/null \
    && apt-mark manual "${APT_MARK[@]}" >/dev/null \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    || :
  apt-get clean -y ||:
}

_reset_env () {
  pkill -9 wine ||:

  _cleanup_apt

  rm -rf "/var/tmp"/* "/tmp"/*
}

trap '_reset_env' EXIT

apt-get install --no-install-recommends -y \
  erofs-utils

wine cmd /c ver

mkdir -p "${_SYMBIAN_MOUNT_SDK}"
mkdir -p "${_SYMBIAN_MOUNT_GCC}"

mkfs.erofs "${EROFS_ARGS[@]}" "${_SYMBIAN_IMAGE_SDK}" "/var/tmp/Nokia_Symbian_Belle_SDK_v1.0"
mkfs.erofs "${EROFS_ARGS[@]}" "${_SYMBIAN_IMAGE_GCC}" "/var/tmp/gcc-12.1.0"
