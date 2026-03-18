{ config, pkgs, ... }:
{
  # Jellyfin
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
