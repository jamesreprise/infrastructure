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

  nixpkgs.config.packageOverrides = pkgs: {
    zfsStable = pkgs.zfsStable.override { enableMail = true; };
  };

  services.zfs.zed.enableMail = true;
  services.zfs.zed.settings = {
    ZED_EMAIL_PROG = "${pkgs.mailutils}/bin/mail";
    ZED_EMAIL_ADDR = [ "james" ];
    ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
  };
}

