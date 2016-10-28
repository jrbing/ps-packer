#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function use_redhat_kernel() {
  echoinfo "Configuring Grub to use RedHat-compatible kernel"
  if grep -q -i "release 7" /etc/redhat-release ; then
    sed -i 's/^GRUB_DEFAULT=saved/GRUB_DEFAULT=0/' /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
  else
    sed -i 's/^default=0/default=1/' /boot/grub/grub.conf
  fi
}

function disable_transparent_hugepages() {
  echoinfo "Disabling transparent hugepages"
  sed -i 's/^GRUB_CMDLINE_LINUX.*quiet/& transparent_hugepages=never/' /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
}

function disable_tuned() {
  echoinfo "Disabling the tuned service"
  systemctl stop tuned
  systemctl disable tuned
}

use_redhat_kernel
disable_transparent_hugepages
disable_tuned

echoinfo "Rebooting the machine"
reboot
sleep 60
