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
    "..."
  ];
  boot.zfs.extraPools = ["zboot"];
  services.zfs.autoScrub.enable = true;
}