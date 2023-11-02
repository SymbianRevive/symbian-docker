#!/usr/bin/env bash
set -xeuo pipefail

cd /var/tmp

declare -a EROFS_ARGS
EROFS_ARGS=(-zlz4)

export DEBIAN_FRONTEND="noninteractive"

dpkg --add-architecture i386

apt-get update

apt-get install --no-install-recommends -y \
  binfmt-support wine wine32:i386 wine-binfmt python3 ninja-build cmake build-essential erofsfuse

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

export WINEPREFIX=/var/lib/nokiaprefix
export WINEARCH=win32

wine cmd /c ver

mkdir -p "${WINEPREFIX}/drive_c/Nokia/devices/Nokia_Symbian_Belle_SDK_v1.0"
mkdir -p "${WINEPREFIX}/drive_c/gcc-12.1.0"

mkfs.erofs "${EROFS_ARGS[@]}" "/Nokia_Symbian_Belle_SDK_v1.0.erofs" "/var/tmp/Nokia_Symbian_Belle_SDK_v1.0/"
mkfs.erofs "${EROFS_ARGS[@]}" "/gcc-12.1.0.erofs" "/var/tmp/gcc-12.1.0/"
