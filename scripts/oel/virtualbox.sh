#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

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

  # Assume that we've installed all the prerequisites:
  # kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc make perl
  # from the install media via ks.cfg
  mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
  sh /mnt/VBoxLinuxAdditions.run --nox11
  umount /mnt
  rm -rf /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso
  rm -f /home/vagrant/.vbox_version

  echoinfo "Removing packages needed for building guest tools"
  yum -y remove gcc cpp kernel-devel kernel-headers perl

}

install_virtualbox_guest_additions
