#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

set -e

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function disable_release_upgrader() {
  echoinfo "Disabling the release upgrader"
  sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades
}

function disable_apt_daily_services() {
  echoinfo "Disabling apt-daily services"
  systemctl disable apt-daily.service
  systemctl disable apt-daily.timer
}

function update_repositories() {
  echoinfo "Updating indexes for repositories"
  apt-get -y update
}

function apply_updates() {
  echoinfo "Applying updates"
  #apt-get -y dist-upgrade --force-yes
  apt-get -y dist-upgrade
}

function reboot_machine() {
  echoinfo "Rebooting the machine"
  reboot
  sleep 60
}

disable_release_upgrader
disable_apt_daily_services
update_repositories
apply_updates
reboot_machine
