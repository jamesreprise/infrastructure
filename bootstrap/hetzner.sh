#!/usr/bin/env bash

# WORK IN PROGRESS - NON-FUNCTIONAL - DO NOT USE

# Takes a Hetzner rescue server and creates a Primetime server running on NixOS.
#
# Adapted from https://github.com/nix-community/nixos-install-scripts/blob/master/hosters/hetzner-dedicated/hetzner-dedicated-wipe-and-install-nixos.sh
#
# and https://mazzo.li/posts/hetzner-zfs.html
#
# and https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/1-preparation.html
#
# using https://gist.github.com/bitonic/78529d3dd007d779d60651db076a321a 
# Usage:
# ssh root@YOUR_SERVERS_IP bash -s < hetzner.sh

# Notes:
# There's a lot of implicit actions in this script. We assume: 
# * that there are four equally sized drives available at /dev/sd{a,b,c,d}.
# * that you want to use ZFS.

# Bash safety settings: 
#
# -e exits if the exit code of a command is non-zero
# -u treats unset variables as errors
# -x echoes every command
# -o pipefail returns the exit value of the rightmost command that returned a 
#    non-zero exit value, or zero if there was no command with a non-zero exit
set -euxo pipefail

# Undo existing setups to allow running the script multiple times to iterate on it.
# We allow these operations to fail for the case the script runs the first time.
set +e
umount /mnt
vgchange -an
set -e

# Create wrapper for parted >= 3.3 that does not exit 1 when it cannot inform
# the kernel of partitions changing (we use partprobe for that).
echo -e "#! /usr/bin/env bash\nset -e\n" 'parted $@ 2> parted-stderr.txt || grep "unable to inform the kernel of the change" parted-stderr.txt && echo "This is expected, continuing" || echo >&2 "Parted failed; stderr: $(< parted-stderr.txt)"' > parted-ignoring-partprobe-error.sh && chmod +x parted-ignoring-partprobe-error.sh

# Create partition tables (--script to not ask)
./parted-ignoring-partprobe-error.sh --script /dev/sd{a,b,c,d} mklabel gpt

# Create partitions (--script to not ask)
#
# We create the 1MB BIOS boot partition at the front.
#
# Note we use "MB" instead of "MiB" because otherwise `--align optimal` has no effect;
# as per documentation https://www.gnu.org/software/parted/manual/html_node/unit.html#unit:
# > Note that as of parted-2.4, when you specify start and/or end values using IEC
# > binary units like "MiB", "GiB", "TiB", etc., parted treats those values as exact
#
# Note: When using `mkpart` on GPT, as per
#   https://www.gnu.org/software/parted/manual/html_node/mkpart.html#mkpart
# the first argument to `mkpart` is not a `part-type`, but the GPT partition name:
#   ... part-type is one of 'primary', 'extended' or 'logical', and may be specified only with 'msdos' or 'dvh' partition tables.
#   A name must be specified for a 'gpt' partition table.
# GPT partition names are limited to 36 UTF-16 chars, see https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_entries_(LBA_2-33).
./parted-ignoring-partprobe-error.sh --script --align optimal /dev/sda -- mklabel gpt mkpart 'bios-boot-partition' 1MB 2MB set 1 bios_grub on mkpart 'zboot' 2MB 2000MB mkpart 'zroot' 2000MB '100%'
./parted-ignoring-partprobe-error.sh --script --align optimal /dev/sdb -- mklabel gpt mkpart 'bios-boot-partition' 1MB 2MB set 1 bios_grub on mkpart 'zboot' 2MB 2000MB mkpart 'zroot' 2000MB '100%'
./parted-ignoring-partprobe-error.sh --script --align optimal /dev/sdc -- mklabel gpt mkpart 'bios-boot-partition' 1MB 2MB set 1 bios_grub on mkpart 'zboot' 2MB 2000MB mkpart 'zroot' 2000MB '100%'
./parted-ignoring-partprobe-error.sh --script --align optimal /dev/sdd -- mklabel gpt mkpart 'bios-boot-partition' 1MB 2MB set 1 bios_grub on mkpart 'zboot' 2MB 2000MB mkpart 'zroot' 2000MB '100%'

# Reload partitions
partprobe

# Wait for all devices to exist
udevadm settle --timeout=5 --exit-if-exists=/dev/sd{a,b,c,d}{1..3}

echo 'deb http://deb.debian.org/debian bullseye-backports main contrib
deb-src http://deb.debian.org/debian bullseye-backports main contrib' >> /etc/apt/sources.list.d/buster-backports.list

echo 'Package: src:zfs-linux
Pin: release n=bullseye-backports
Pin-Priority: 990' >> /etc/apt/preferences.d/90_zfs

apt update
apt install -y dpkg-dev linux-headers-$(uname -r) linux-image-amd64
apt install -y zfs-dkms zfsutils-linux

set +e
# Hetzner has some home-made install process for zfs
yes | zpool list

# Destroy existing zpool, just in case.
zpool destroy \
    -f zroot

zpool destroy \
    -f zboot
set -e

# Create the boot pool and the root pool. The boot pool is mirrored over all
# disks, but the root pool uses raidz.

DISKS=$(ls /dev/disk/by-id/* | grep ata | grep -v part)

zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=none \
    -R /mnt \
    zboot \
    mirror \
    $(for i in ${DISKS}; do
       printf "$i-part2 ";
      done) -f

zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=none \
    -R /mnt \
    zroot \
    raidz \
    $(for i in ${DISKS}; do
       printf "$i-part3 ";
      done) -f

# Create root system container:
zfs create -o mountpoint=none zroot/main

# Create system datasets:
zfs create -o canmount=on -o mountpoint=/     zroot/main/root
zfs create -o canmount=on -o mountpoint=/home zroot/main/home
zfs create -o canmount=off -o mountpoint=/var  zroot/main/var
zfs create -o canmount=on  zroot/main/var/lib
zfs create -o canmount=on  zroot/main/var/log

# Create boot datasets:
zfs create -o canmount=off -o mountpoint=none zboot/main
zfs create -o canmount=on -o mountpoint=/boot zboot/main/root

mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

# Creating file systems changes their UUIDs.
# Trigger udev so that the entries in /dev/disk/by-uuid get refreshed.
# `nixos-generate-config` depends on those being up-to-date.
# See https://github.com/NixOS/nixpkgs/issues/62444
udevadm trigger

# Wait for FS labels to appear
udevadm settle --timeout=5 --exit-if-exists=/dev/disk/by-label/root

# Installing nix

# Installing nix requires `sudo`; the Hetzner rescue mode doesn't have it.
apt-get install -y sudo

mkdir -p /etc/nix

addgroup nixbld
adduser nixbld1 --disabled-password --gecos '' && addgroup nixbld1 nixbld
adduser nixbld2 --disabled-password --gecos '' && addgroup nixbld2 nixbld
adduser nixbld3 --disabled-password --gecos '' && addgroup nixbld3 nixbld
adduser nixbld4 --disabled-password --gecos '' && addgroup nixbld4 nixbld
adduser nixbld5 --disabled-password --gecos '' && addgroup nixbld5 nixbld
adduser nixbld6 --disabled-password --gecos '' && addgroup nixbld6 nixbld
adduser nixbld7 --disabled-password --gecos '' && addgroup nixbld7 nixbld
adduser nixbld8 --disabled-password --gecos '' && addgroup nixbld8 nixbld
curl -L https://nixos.org/nix/install | sh
set +u +x # sourcing this may refer to unset variables that we have no control over
. $HOME/.nix-profile/etc/profile.d/nix.sh
set -u -x

# Keep in sync with `system.stateVersion` set below!
nix-channel --add https://nixos.org/channels/nixos-22.11 nixpkgs
nix-channel --update

# Getting NixOS installation tools
nix-env -iE "_: with import <nixpkgs/nixos> { configuration = {}; }; with config.system.build; [ nixos-generate-config nixos-install nixos-enter manual.manpages ]"

nixos-generate-config --root /mnt

cat > /mnt/etc/nixos/zfs.nix <<EOF
{ config, pkgs, ... }:

{  
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.devices = [
EOF

for i in $DISKS; do
  printf "      \"$i\"\n" >> /mnt/etc/nixos/zfs.nix
done

cat >> /mnt/etc/nixos/zfs.nix <<EOF
    ];
  boot.zfs.extraPools = ["zboot"]; 
  services.zfs.autoScrub.enable = true;
}
EOF

sed -i '/fileSystems."\/boot" =/,+4 d' /mnt/etc/nixos/hardware-configuration.nix
sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' \
/mnt/etc/nixos/hardware-configuration.nix

# Find the name of the network interface that connects us to the Internet.
# Inspired by https://unix.stackexchange.com/questions/14961/how-to-find-out-which-interface-am-i-using-for-connecting-to-the-internet/302613#302613
RESCUE_INTERFACE=$(ip route get 8.8.8.8 | grep -Po '(?<=dev )(\S+)')

# Find what its name will be under NixOS, which uses stable interface names.
# See https://major.io/2015/08/21/understanding-systemds-predictable-network-device-names/#comment-545626
# NICs for most Hetzner servers are not onboard, which is why we use
# `ID_NET_NAME_PATH`otherwise it would be `ID_NET_NAME_ONBOARD`.
INTERFACE_DEVICE_PATH=$(udevadm info -e | grep -Po "(?<=^P: )(.*${RESCUE_INTERFACE})")
UDEVADM_PROPERTIES_FOR_INTERFACE=$(udevadm info --query=property "--path=$INTERFACE_DEVICE_PATH")
NIXOS_INTERFACE=$(echo "$UDEVADM_PROPERTIES_FOR_INTERFACE" | grep -o -E 'ID_NET_NAME_PATH=\w+' | cut -d= -f2)
echo "Determined NIXOS_INTERFACE as '$NIXOS_INTERFACE'"

IP_V4=$(ip route get 8.8.8.8 | grep -Po '(?<=src )(\S+)')
echo "Determined IP_V4 as $IP_V4"

# Determine Internet IPv6 by checking route, and using ::1
# (because Hetzner rescue mode uses ::2 by default).
# The `ip -6 route get` output on Hetzner looks like:
#   # ip -6 route get 2001:4860:4860:0:0:0:0:8888
#   2001:4860:4860::8888 via fe80::1 dev eth0 src 2a01:4f8:151:62aa::2 metric 1024  pref medium
IP_V6="$(ip route get 2001:4860:4860:0:0:0:0:8888 | head -1 | cut -d' ' -f7 | cut -d: -f1-4)::1"
echo "Determined IP_V6 as $IP_V6"


# From https://stackoverflow.com/questions/1204629/how-do-i-get-the-default-gateway-in-linux-given-the-destination/15973156#15973156
read _ _ DEFAULT_GATEWAY _ < <(ip route list match 0/0); echo "$DEFAULT_GATEWAY"
echo "Determined DEFAULT_GATEWAY as $DEFAULT_GATEWAY"

# Generate `configuration.nix`. Note that we splice in shell variables.
cat > /mnt/etc/nixos/configuration.nix << EOF
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix ./zfs.nix
    ];

  # Networking
  networking.hostId = "$(head -c 8 /etc/machine-id)";
  networking.hostName = "primetime";
  networking.useDHCP = false;
  networking.interfaces."$NIXOS_INTERFACE".ipv4.addresses = [
    {
      address = "$IP_V4";
      # The prefix length is commonly, but not always, 24.
      # You should check what the prefix length is for your server
      # by inspecting the netmask in the "IPs" tab of the Hetzner UI.
      # For example, a netmask of 255.255.255.0 means prefix length 24
      # (24 leading 1s), and 255.255.255.192 means prefix length 26
      # (26 leading 1s).
      prefixLength = 26;
    }
  ];
  networking.interfaces."$NIXOS_INTERFACE".ipv6.addresses = [
    {
      address = "$IP_V6";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "$DEFAULT_GATEWAY";
  networking.defaultGateway6 = { address = "fe80::1"; interface = "$NIXOS_INTERFACE"; };
  networking.nameservers = [ "8.8.8.8" ];

  # Services
  services.openssh.permitRootLogin = "prohibit-password";

  # Users
  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8fjbXSBBYlm7tO8Zn6AEPjBm63jTNdhSe9oCIp3ocADNEqG92a25OaVLCO5O9ZDNQCnzE2i4Y2TXxYnz95uHnReb7DXkbyAIdx71X91esW4zPtI4zLzpHB4Hlfy7vzcXA0CsQJ5cFl4jgjiHV2+73YQvULbt6fqvldNRhq4F3hc8tBlPThwz0tPugZO0hvhz4G1crt2gRgcvdvBUtYhmgwEPHR9MlVtms1Z6khVJVYJ3Dawcd/V+4gtaiTLUohmD98HM/Tt1RP2SAtTBQ5L6LiZz4Igs5PYbnv/w3yYNMLusSfVjTUV1Ch0NJC8uJM15Rwm9RBYGmrjopLGGuIby3EkFgBJnvPQzJ+3+20TWmh5QKCsWx7K2Fv54AGndUP0Tq3acwzECp2o86mokxgCQyppTu7OnUFRAm69iux8wYWWcnxfDpgDM9wEJPCQ3bZ0IT43uDU5HCFZNGLUiEQEFTgZoM6lLtYO76JRChn1rJtq1M87ZnuaxA08g7LZz7S7c="
  ];
  users.users.james = {
    isNormalUser = true;
    home = "/home/james";
    group = "james";
    hashedPassword = "\$6$//tchRyrimZs.vMU\$jyxsh1apQ5EVxltobG/umHBp3B7BHA/X3qJwoA1BRk6QB5fjYCK9dphkTVUCl78IacgHD/XLljCOLY4k.f1OG/";
    extraGroups = ["wheel"];
  };
  users.groups.james = {};
  services.openssh.enable = true;


  # Nix 
  nix.nixPath = [
    "nixpkgs=https://nixos.org/channels/nixpkgs-unstable"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  #
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11"; 
}
EOF

# Install NixOS
PATH="$PATH" `which nixos-install` --no-root-passwd --root /mnt --max-jobs 40

# I think we need to add an unmount here, otherwise we get an error which requires a
# kvm session to resolve. zboot won't mount with the reason: 
# pool was previously in use from another system

umount -Rl /mnt
zpool export -a

# Could require some other fix.

reboot
