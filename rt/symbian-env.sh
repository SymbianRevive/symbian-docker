#!/usr/bin/env bash
export WINEPREFIX="${WINEPREFIX:-/var/lib/nokiaprefix}"
export WINEARCH="${WINEARCH:-win32}"
export WINEDEBUG="-all"

export SYMBIAN_GCC_ROOT="${SYMBIAN_GCC_ROOT:-${WINEPREFIX}/drive_c/gcc-12.1.0/}"
export EPOCROOT="${EPOCROOT:-${WINEPREFIX}/drive_c/Nokia/devices/Nokia_Symbian_Belle_SDK_v1.0/}"

export _SYMBIAN_MOUNT_SDK="${EPOCROOT}"
export _SYMBIAN_MOUNT_GCC="${SYMBIAN_GCC_ROOT}"

export _SYMBIAN_IMAGE_SDK="/Nokia_Symbian_Belle_SDK_v1.0.erofs"
export _SYMBIAN_IMAGE_GCC="/gcc-12.1.0.erofs"

export PATH="${PATH}:${_SYMBIAN_MOUNT_GCC}/bin:${EPOCROOT}/epoc32/tools"

if (( _BUILD_CONTAINER != 1 )) ; then
  if ! mountpoint "${_SYMBIAN_MOUNT_SDK}" &>/dev/null ; then
    mkdir -p "${_SYMBIAN_MOUNT_SDK}" \
      && erofsfuse "${_SYMBIAN_IMAGE_SDK}" "${_SYMBIAN_MOUNT_SDK}" &>/dev/null \
      || >&2 echo "Failed to mount SDK"
  fi

  if ! mountpoint "${_SYMBIAN_MOUNT_GCC}" &>/dev/null ; then
    mkdir -p "${_SYMBIAN_MOUNT_GCC}" \
      && erofsfuse "${_SYMBIAN_IMAGE_GCC}" "${_SYMBIAN_MOUNT_GCC}" &>/dev/null \
      || >&2 echo "Failed to mount GCC"
  fi

  /sbin/update-binfmts --enable wine &>/dev/null ||:
fi
