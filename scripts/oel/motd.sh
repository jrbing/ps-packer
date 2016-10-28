#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function record_box_generation_date() {
  echoinfo "Recording box generation date"
  date > /etc/vagrant_box_build_date
}

function echobanner() {
  # TODO: figure out how to enable color support for MOTD and add banner
cat << EndOfBanner
                                      dP                               dP
                                      88                               88
  dP   .dP .d8888b. .d8888b. .d8888b. 88d888b. .d8888b. 88d888b. .d888b88
  88   d8' 88'  \`88 88'  \`88 88'  \`88 88'  \`88 88'  \`88 88'  \`88 88'  \`88
  88 .88'  88.  .88 88.  .88 88.  .88 88.  .88 88.  .88 88    88 88.  .88
  8888P'   \`88888P8 \`8888P88 \`88888P8 88Y8888' \`88888P' dP    dP \`88888P8
                         .88
                     d8888P
EndOfBanner
}

function customize_motd() {
  echoinfo "Customizing message of the day"
  local MOTD_FILE=/etc/motd
  local PLATFORM_RELEASE=$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release)
  local PLATFORM_MSG=$(printf 'Oracle Linux %s' "$PLATFORM_RELEASE")
  local BUILT_MSG="$(printf 'built %s' $(date +%Y-%m-%d))"
  printf '%0.1s' "-"{1..64} > ${MOTD_FILE}
  printf '\n' >> ${MOTD_FILE}
  printf '%2s%-30s%30s\n' " " "${PLATFORM_MSG}" "${BUILT_MSG}" >> ${MOTD_FILE}
  printf '%0.1s' "-"{1..64} >> ${MOTD_FILE}
  printf '\n' >> ${MOTD_FILE}
}

record_box_generation_date
customize_motd
