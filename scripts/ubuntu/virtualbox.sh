#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

set -e

HOME_DIR="${HOME_DIR:-/home/vagrant}";

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function install_virtualbox_guest_additions() {
  local VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
  echoinfo "Virtualbox Tools Version: $VBOX_VERSION";
  echoinfo "Installing VirtualBox guest additions"
  mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
  sh /mnt/VBoxLinuxAdditions.run --nox11
  umount /mnt
  rm -rf /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso
  rm -f /home/vagrant/.vbox_version
}

install_virtualbox_guest_additions
