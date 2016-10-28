#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

set -e

SSH_USERNAME=${SSH_USERNAME:-vagrant}
SSH_PASSWORD=${SSH_PASSWORD:-vagrant}
SSH_USER_HOME="/home/${SSH_USERNAME}"
VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function add_vagrant_user() {
  echoinfo 'Adding vagrant user'
  if ! id -u "$SSH_USERNAME" >/dev/null 2>&1; then
    /usr/sbin/groupadd "$SSH_USERNAME"
    /usr/sbin/useradd "$SSH_USERNAME" -g "$SSH_USERNAME" -G sudo -d "$SSH_USER_HOME" --create-home
    echo "${SSH_USERNAME}:${SSH_PASSWORD}" | chpasswd
  fi
}

function grant_vagrant_user_sudo() {
  echoinfo "Granting ${SSH_USERNAME} sudo rights"
  echo "${SSH_USERNAME}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/"$SSH_USERNAME"
  chmod 440 /etc/sudoers.d/"$SSH_USERNAME"
}

function fix_stdin_tty() {
  if grep -q -E "^mesg n$" /root/.profile && sed -i "s/^mesg n$/tty -s \\&\\& mesg n/g" /root/.profile; then
    echoinfo "Fixed stdin tty issue"
  fi
}

function install_vagrant_ssh_key() {
  echoinfo 'Installing Vagrant SSH key'
  mkdir -pm 700 "${SSH_USER_HOME}/.ssh"
  # https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
  echo "${VAGRANT_INSECURE_KEY}" > "$SSH_USER_HOME/.ssh/authorized_keys"
  chmod 0600 "${SSH_USER_HOME}/.ssh/authorized_keys"
  chown -R "${SSH_USERNAME}:${SSH_USERNAME}" "${SSH_USER_HOME}"/.ssh
}

add_vagrant_user
grant_vagrant_user_sudo
fix_stdin_tty
install_vagrant_ssh_key
