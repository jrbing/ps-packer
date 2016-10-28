#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

#set -e

DISK_USAGE_BEFORE_CLEANUP=$(df -h)

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function cleanup_udev_persistence() {
  echoinfo "Cleaning up udev persistence"
  rm -rfv /dev/.udev/
  #rm /lib/udev/rules.d/75-persistent-net-generator.rules
}

function fix_network_interfaces() {
  echoinfo "Fixing network interfaces"
  sed -i "s/ens33/ens32/g" /etc/network/interfaces
  echo "pre-up sleep 2" >> /etc/network/interfaces
}

function clean_remote_temp_files() {
  echoinfo "Cleaning remote temporary files used to build box"
  rm -rfv /tmp/*
}

function clean_packages() {
  echoinfo "Removing mdadm"
  apt-get -y purge mdadm

  echoinfo "Removing development packages"
  dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge

  echoinfo "Removing X11 libraries"
  apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6

  echoinfo "Removing miscellaneous packages"
  apt-get -y purge popularity-contest installation-report
}

function remove_man_pages() {
  echoinfo "Removing man pages"
  rm -rfv /usr/share/man/*
}

function remove_apt_files() {
  echoinfo "Removing APT files"
  #find /var/lib/apt -type f | xargs rm -f
  find /var/lib/apt -type f -print0 | xargs -0 rm -f
}

function remove_docs() {
  echoinfo "Removing docs"
  rm -rfv /usr/share/doc/*
}

function remove_cache() {
  echoinfo "Removing caches"
  find /var/cache -type f -exec rm -rfv {} \;
}

function clean_apt_cache() {
  echoinfo "Cleaning up apt cache"
  apt-get -y autoremove --purge
  apt-get -y clean
  apt-get -y autoclean
}

function remove_bash_history() {
  echoinfo "Removing bash history"
  unset HISTFILE
  rm -f /root/.bash_history
  rm -f /home/vagrant/.bash_history
}

function clean_log_files() {
  echoinfo "Cleaning up log files"
  find /var/log -type f | while read f; do echo -ne '' > "${f}"; done;
}

function clear_last_login_information() {
  echoinfo "Clearing last login information"
  >/var/log/lastlog
  >/var/log/wtmp
  >/var/log/btmp
}

function clear_and_disable_swap() {
  echoinfo 'Clearing swap and disabling until reboot'
  set +e
  swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
  case "$?" in
    2|0) ;;
    *) exit 1 ;;
  esac

  set -e

  if [[ "x${swapuuid}" != "x" ]]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart=$(readlink -f /dev/disk/by-uuid/"$swapuuid")
    /sbin/swapoff "${swappart}"
    dd if=/dev/zero of="${swappart}" bs=1M || echo "dd exit code $? is suppressed"
    /sbin/mkswap -U "${swapuuid}" "${swappart}"
  fi
}

function zero_empty_space() {
  echoinfo 'Zeroing out empty area to save space in the final image'
  # Zero out the free space to save space in the final image.  Contiguous
  # zeroed space compresses down to nothing.
  dd if=/dev/zero of=/EMPTY bs=1M || echo "dd exit code $? is suppressed"
  rm -f /EMPTY
  # Block until the empty file has been removed, otherwise, Packer
  # will try to kill the box while the disk is still full and that's bad
  sync
}


function print_disk_savings() {
  echoinfo "Disk usage before cleanup"
  echo "${DISK_USAGE_BEFORE_CLEANUP}"

  echoinfo "Disk usage after cleanup"
  df -h
}

cleanup_udev_persistence
fix_network_interfaces
clean_remote_temp_files
clean_packages
remove_man_pages
remove_apt_files
remove_docs
remove_cache
clean_apt_cache
remove_bash_history
clean_log_files
clear_last_login_information
clear_and_disable_swap
zero_empty_space
print_disk_savings
