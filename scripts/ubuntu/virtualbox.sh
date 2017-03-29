#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

readonly VBOX_VERSION=$(cat /home/vagrant/.vbox_version)

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function install_virtualbox_guest_additions() {
  echoinfo "Virtualbox version: $VBOX_VERSION"
  echoinfo "Installing VirtualBox guest additions"
  mount -o loop,ro /home/vagrant/VBoxGuestAdditions_"$VBOX_VERSION".iso /mnt
  /mnt/VBoxLinuxAdditions.run --nox11
  sleep 15
  echoinfo "VirtualBox guest additions installed successfully"

  echoinfo "Unmounting guest additions iso"
  umount /mnt

  echoinfo "Cleaning up guest additions installation files"
  rm -rfv /home/vagrant/VBoxGuestAdditions_"$VBOX_VERSION".iso
  rm -fv /home/vagrant/.vbox_version
}

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
  install_virtualbox_guest_additions
fi
