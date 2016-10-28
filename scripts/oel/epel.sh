#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

EPEL_URL="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function install_epel_repo() {
  echoinfo "Adding EPEL repo"
  rpm -Uvh "$EPEL_URL"
}

install_epel_repo
