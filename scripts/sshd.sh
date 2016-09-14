#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

SSHD_CONFIG="/etc/ssh/sshd_config"

# ensure that there is a trailing newline before attempting to concatenate
# shellcheck disable=1003
sed -i -e '$a\' "$SSHD_CONFIG"

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

function disable_ssh_dns_lookup() {
  echoinfo "Turning off sshd DNS lookup to prevent timeout delay"
  local USEDNS="UseDNS no"
  if grep -q -E "^[[:space:]]*UseDNS" "$SSHD_CONFIG"; then
    sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$SSHD_CONFIG"
  else
    echo "$USEDNS" >>"$SSHD_CONFIG"
  fi
}

function disable_gssapi_auth() {
  echoinfo "Disablng GSSAPI authentication to prevent timeout delay"
  local GSSAPI="GSSAPIAuthentication no"
  if grep -q -E "^[[:space:]]*GSSAPIAuthentication" "$SSHD_CONFIG"; then
    sed -i "s/^\s*GSSAPIAuthentication.*/${GSSAPI}/" "$SSHD_CONFIG"
  else
    echo "$GSSAPI" >>"$SSHD_CONFIG"
  fi
}

function disable_root_login() {
  echoinfo "Disabling root login"
  local PermitRootLogin="PermitRootLogin no"
  if grep -q -E "^.PermitRootLogin" "$SSHD_CONFIG"; then
    sed -i -e "s/#PermitRootLogin.*/${PermitRootLogin}/" "$SSHD_CONFIG"
  else
    echo "$PermitRootLogin" >>"$SSHD_CONFIG"
  fi
}

disable_ssh_dns_lookup
disable_gssapi_auth
disable_root_login
