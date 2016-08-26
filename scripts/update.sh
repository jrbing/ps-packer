#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function apply_updates() {
  echoinfo "Applying updates"
  yum -y update
}

function reboot_machine() {
  echoinfo "Rebooting the machine"
  reboot
  sleep 60
}

apply_updates
reboot_machine
