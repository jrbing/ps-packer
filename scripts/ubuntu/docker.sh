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

function install_zfs() {
  echoinfo "Installing zfs"
  apt-get update
  apt-get install -y zfs
  apt-get install -y zfsutils-linux
}

function create_zpool() {
  echoinfo "Creating new zpool"
  zpool create -f zpool-docker /dev/sdb
}

function mount_zpool() {
  echoinfo "Mounting zpool at /var/lib/docker"
  zfs create -o mountpoint=/var/lib/docker zpool-docker/docker
}

function install_docker_prerequisites() {
  set +e
  echoinfo "Installing docker prerequisites"
  apt-key update
  apt-get install apt-transport-https ca-certificates
  # TODO: figure out why the keys can't be imported
  #apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get -y install linux-image-extra-"$(uname -r)" linux-image-extra-virtual
  set -e
}

function install_docker() {
  echoinfo "Installing docker"
  apt-cache policy docker-engine
  apt-get install --allow-unauthenticated -y docker-engine
}

function shutdown_docker() {
  echoinfo "Stopping docker service"
  systemctl stop docker
}

function clean_docker_lib() {
  echoinfo "Cleaning docker lib"
  rm -rf /var/lib/docker/*
}

function update_docker_storage_driver() {
  echoinfo "Updating docker storage driver"
  sed -i '/^ExecStart/ s/$/ -H tcp:\/\/0.0.0.0:2375 --storage-driver=zfs/' /lib/systemd/system/docker.service
}

function restart_docker_service() {
  echoinfo "Restarting docker service"
  systemctl daemon-reload
  systemctl enable docker
  systemctl start docker
}

function add_vagrant_user_to_docker_group() {
  echoinfo "Adding vagrant user to docker group"
  usermod -aG docker vagrant
}

function install_portainer_service() {
  echoinfo "Installing portainer service"
  cp /home/vagrant/portainer.service /etc/systemd/system/portainer.service
  systemctl daemon-reload
  systemctl enable portainer
  systemctl start portainer
}

install_zfs
create_zpool
mount_zpool
install_docker_prerequisites
install_docker
shutdown_docker
clean_docker_lib
update_docker_storage_driver
restart_docker_service
add_vagrant_user_to_docker_group
install_portainer_service
