#!/bin/bash

set -eE -o functrace

fatal() {
  local LINE="$1"
  local CMD="$2"
  echo "[FATAL] $LINE: $CMD" >&2
}

trap 'fatal "$LINENO" "$BASH_COMMAND"' ERR

# functions

validate_environment() {
  echo "::group::Validating environment"

  echo "BASH_VERSION: [$BASH_VERSION]"
  echo

  echo "Validating required commands"
  local FOUND=true
  for CMD in curl jq tee; do
    echo -n "- [$CMD] "
    if which "$CMD" >/dev/null 2>&1; then
      echo "[FOUND]"
      $CMD --version
      echo
    else
      echo "[NOT FOUND]"
      FOUND=false
    fi
  done

  if [[ $FOUND == false ]]; then
    echo "Required commands not found!"
    echo "See above logs for detals. Exiting..."
    exit 1
  fi

  echo "::endgroup::"
}

# start

validate_environment
