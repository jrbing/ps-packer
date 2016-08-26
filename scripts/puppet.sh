#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

# PUPPET_VERSION variable should be set inside of Packer's template:
#
# Values for PUPPET_VERSION can be
#   'x.y.z'           -- build a box with version x.y.z
#   'x.y'             -- build a box with version x.y
#   'latest'          -- build a box with the latest version
#
# Set PUPPET_VERSION to 'latest' if unset because it can be problematic
# to set variables in pairs with Packer (and Packer does not support
# multi-value variables).
PUPPET_VERSION=${PUPPET_VERSION:-latest}

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function install_puppet() {
  echoinfo "Installing Puppet"
  REDHAT_MAJOR_VERSION=$(egrep -Eo 'release ([0-9][0-9.]*)' /etc/redhat-release | cut -f2 -d' ' | cut -f1 -d.)

  echoinfo "Installing Puppet Labs repositories"
  rpm -ipv "http://yum.puppetlabs.com/puppetlabs-release-el-${REDHAT_MAJOR_VERSION}.noarch.rpm"

  if [[ ${PUPPET_VERSION:-} == 'latest' ]]; then
    echo "==> Installing latest Puppet version"
    yum -y install puppet
  else
    echo "Installing Puppet version ${PUPPET_VERSION}"
    yum -y install "puppet-${PUPPET_VERSION}"
  fi
}

function install_eyaml() {
  echoinfo "Installing hiera-eyaml"
  gem install hiera-eyaml
}

install_puppet
install_eyaml
