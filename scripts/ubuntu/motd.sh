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

function record_box_generation_date() {
  echoinfo "Recording box generation date"
  date > /etc/vagrant_box_build_date
}

function customize_motd() {
  echoinfo "Customizing message of the day"
  local MOTD_FILE=/etc/motd
  local PLATFORM_RELEASE=$(lsb_release -sd)
  local PLATFORM_MSG=$(printf '%s' "$PLATFORM_RELEASE")
  local BUILT_MSG="$(printf 'built %s' $(date +%Y-%m-%d))"
  printf '%0.1s' "-"{1..64} > ${MOTD_FILE}
  printf '\n' >> ${MOTD_FILE}
  printf '%2s%-30s%30s\n' " " "${PLATFORM_MSG}" "${BUILT_MSG}" >> ${MOTD_FILE}
  printf '%0.1s' "-"{1..64} >> ${MOTD_FILE}
  printf '\n' >> ${MOTD_FILE}
}

record_box_generation_date
customize_motd
