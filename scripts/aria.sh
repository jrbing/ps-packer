#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

ARIA_PATH="/tmp/${ARIA_RPM}"

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function install_aria() {
  echoinfo "Installing aria2 from ${ARIA_PATH}"
  rpm -Uvh "$ARIA_PATH"
}

install_aria
