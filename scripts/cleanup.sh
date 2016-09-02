#!/bin/bash -eux
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en ft=sh
#===============================================================================

DISK_USAGE_BEFORE_CLEANUP=$(df -h)

function echoinfo() {
  local BC="\033[1;34m"
  local EC="\033[0m"
  printf "${BC} ☆  INFO${EC}: %s\n" "$@";
}

# Other locales will be removed from the VM
KEEP_LANGUAGE="en"

function cleanup_udev_persistence() {
  echoinfo "Cleaning up udev persistence"
  # Clean up network interface persistence
  if grep -q -i "release 6" /etc/redhat-release ; then
    rm -f /etc/udev/rules.d/70-persistent-net.rules
    mkdir /etc/udev/rules.d/70-persistent-net.rules
    rm /lib/udev/rules.d/75-persistent-net-generator.rules
  fi
  rm -rf /dev/.udev/

  for ndev in `ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "$(basename $ndev)" != "ifcfg-lo" ]; then
      sed -i '/^HWADDR/d' "$ndev";
      sed -i '/^UUID/d' "$ndev";
    fi
  done
}

function cleanup_network_adapters() {
echoinfo "Cleaning up network adapters"
# radio off & remove all interface configration
nmcli radio all off
/bin/systemctl stop NetworkManager.service
for ifcfg in $(ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v ifcfg-lo) ; do
  rm -f "$ifcfg"
done
rm -rf /var/lib/NetworkManager/*

echo "Setup /etc/rc.d/rc.local for OEL7"
cat <<_EOF_ | cat >> /etc/rc.d/rc.local
#VAGABOND-BEGIN
LANG=C
# delete all connection
for con in \`nmcli -t -f uuid con\`; do
  if [ "\$con" != "" ]; then
    nmcli con del \$con
  fi
done
# add gateway interface connection.
gwdev=\`nmcli dev | grep ethernet | egrep -v 'unmanaged' | head -n 1 | awk '{print \$1}'\`
if [ "\$gwdev" != "" ]; then
  nmcli c add type eth ifname \$gwdev con-name \$gwdev
fi
sed -i "/^#VAGABOND-BEGIN/,/^#VAGABOND-END/d" /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
#VAGABOND-END
_EOF_
chmod +x /etc/rc.d/rc.local
}

function remove_unused_man_locales() {
  echoinfo "Remove unused man page locales"
  pushd /usr/share/man
  if [ $(ls | wc -w) -gt 16 ]; then
    mkdir ../tmp_dir
    mv man* $KEEP_LANGUAGE ../tmp_dir
    rm -rf *
    mv ../tmp_dir/* .
    rm -rf ../tmp_dir
    sync
  fi
  popd
}

function remove_guest_tools_build_package() {
  echoinfo "Removing packages needed to build the guest tools"
  #yum -y remove gcc cpp libmpc mpfr kernel-devel kernel-headers perl
  yum -y remove gcc cpp libmpc mpfr kernel-devel kernel-headers
  #libstdc++
}

# TODO: find and remove unnecessary packages
#function remove_unnecessary_packages() {
 #acl acpid amtu apmd aspell aspell-en at attr audit anacron atk authconfig autofs bc bind-libs
 #bind-utils binutils bitstream-vera-fonts bluez-gnome bluez-libs bluez-utils bzip2 cairo ccid conman coolkey
 #cpp cpuspeed crash cryptsetup-luks cups-libs cyrus-sasl cyrus-sasl-plain dbus dbus-glib dbus-libs dbus-python
 #desktop-file-utils dhclient dhcpv6-client dmidecode dnsmasq dos2unix dosfstools dump ecryptfs-utils ed eject
 #fbset file finger firstboot-tui flex fontconfig freetype ftp gamin gamin-python gcc gcc-c++ GConf2 gettext
 #glibc-devel glibc-headers gnu-efi gnutls gpm groff gtk2 hal hesiod hdparm hicolor-icon-theme htmlview ibmasm
 #ifd-egate ipsec-tools iptables-ipv6 iptraf iptstate irda-utils irqbalance jwhois kernel-PAE-devel kernel-devel
 #kernel-headers keyutils krb5-workstation ksh kudzu lftp libaio libdaemon libevent libgcrypt libgomp libgpg-error
 #libgssapi libhugetlbfs libICE libIDL libjpeg libnotify libpng libSM libstdc++-devel libtiff libvolume_id libwnck
 #libX11 libXau libXcursor libXdmcp libXext libXfixes libXft libXi libXinerama libxml2-python libXrandr libXrender
 #libXres logwatch lsof m4 mailcap mailx make man man-pages mdadm mgetty microcode_ctl mkbootdisk mlocate mtools
 #mtr nano nc NetworkManager NetworkManager-glib newt nfs-utils nfs-utils-lib notification-daemon nscd nss_db
 #nss_ldap nss-tools ntsysv numactl ORBit2 oddjob oddjob-libs pam_ccreds pam_krb5 pam_passwdqc pam_pkcs11 pam_smb
 #pango parted patch pax pcmciautils pcsc-lite pcsc-lite-libs perl perl-String-CRC32 pinfo pkinit-nss pm-utils
 #portmap ppp prelink procmail psacct pygobject2 quota rdate rdist readahead redhat-lsb redhat-menus rhpl rmt
 #rng-utils rp-pppoe rsh rsync screen sendmail setarch setools setserial setuptool slang smartmontools sos specspo
 #startup-notification stunnel sudo sysfsutils syslinux system-config-network-tui system-config-securitylevel-tui
 #talk tcl tcpdump tcsh telnet time tmpwatch traceroute tree trousers unix2dos unzip udftools usbutils vconfig
 #vim-enhanced wget wireless-tools words wpa_supplicant xorg-x11-filesystem ypbind yp-tools yum-updatesd zip
#}

function clean_yum_cache() {
  echoinfo "Cleaning up yum cache"
  yum -y clean all
}

function clean_core_files() {
  echoinfo "Cleaning up core files"
  rm -f /core*
}

function clean_remote_temp_files() {
  echoinfo "Cleaning remote temporary files used to build box"
  rm -rf /tmp/*
}

function rebuild_rpm_db() {
  echoinfo "Rebuilding RPM Database"
  rpmdb --rebuilddb
  rm -f /var/lib/rpm/__db*
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

  if [ "x${swapuuid}" != "x" ]; then
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
cleanup_network_adapters
remove_unused_man_locales
remove_guest_tools_build_package
clean_yum_cache
clean_core_files
clean_remote_temp_files
rebuild_rpm_db
clear_and_disable_swap
zero_empty_space
print_disk_savings
