#!/usr/bin/env bash
set -euo pipefail

_clean_up () {
  rm -rf "${TEMP_DIR}"

  >&2 echo " ==> Fixing permissions..."
  chown -R "${SUDO_UID}" "${BUILD_DIR}"
}

main () {
  SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]:-$1}")"

  if (( EUID != 0 )) ; then
    if command -v sudo &>/dev/null ; then
      sudo "${SHELL}" "$@"
    else
      >&2 echo " ==> This script MUST be run by a normal user using sudo!"
      exit 1
    fi
  elif (( SUDO_UID == 0 )) ; then
    >&2 echo " ==> This script MUST be run by a normal user using sudo!"
    exit 1
  fi

  if (( EUID != 0 )) || (( SUDO_UID == 0 )); then
    >&2 echo " ==> This script MUST be run by a normal user using sudo!"
    exit 1
  fi

  shift  # NOTE: This only removes the $0 passed to main

  OCI_EXE="${OCI_EXE:-$(command -v docker ||:)}"
  OCI_EXE="${OCI_EXE:-$(command -v podman ||:)}"
  OCI_EXE="${OCI_EXE:?neither docker nor podman are available on this system}"

  SOURCE_DIR="${1:?Usage: sdk.sh SOURCE_DIR BUILD_DIR CMAKE_ARGS...}"
  shift
  BUILD_DIR="${1:?Usage: sdk.sh SOURCE_DIR BUILD_DIR CMAKE_ARGS...}"
  shift

  mkdir -p "${BUILD_DIR}"

  if [[ ! -d "${SOURCE_DIR}" ]] ; then
    >&2 echo "\"${SOURCE_DIR}\" is not a directory!"
    exit 1
  fi

  TEMP_DIR="$(mktemp -d)"

  trap '_clean_up' EXIT

  OCI_IMAGE="${OCI_IMAGE:-symbian}"

  LOAD_TAG="${LOAD_TAG:-latest}"
  LOAD_URL="${LOAD_URL:-https://github.com/I-asked/symbian-docker/releases/$LOAD_TAG/downloads/symbian.txz}"

  LOAD_OUT="${LOAD_OUT:-$TEMP_DIR/symbian.txz}"

  if ! "${OCI_EXE}" image inspect "${OCI_IMAGE}" &>/dev/null ; then
    >&2 echo " ==> Image not found, will download now..."
    if wget -O "${LOAD_OUT}" "${LOAD_URL}" ; then
      xz -d "${OCI_EXE}" - |"${OCI_EXE}" image import -
    elif [[ -d "${SCRIPT_PATH}/external/Nokia_Symbian_Belle_SDK_v1.0" ]] \
        && [[ -d "${SCRIPT_PATH}/external/gcc-12.1.0" ]] ; then
      >&2 echo " ==> Could not download the image, will build now..."
      "${OCI_EXE}" build "${SCRIPT_PATH}" --tag "${OCI_IMAGE}"
    else
      >&2 echo " ==> Could not download or build the image, the external runtime files are missing!"
      exit 1
    fi
  fi

  "${OCI_EXE}" run --privileged -it --rm -v "${SOURCE_DIR}":/sourcedir -v "${BUILD_DIR}":/builddir "${OCI_IMAGE}" autocmake -S /sourcedir -B /builddir "$@"
}

main "$0" "$@"
