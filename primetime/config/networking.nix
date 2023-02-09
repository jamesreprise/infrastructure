{ config, pkgs, ...}:

# WIP
{
  systemd.network.netdevs."wg0" = {
    enable = true;
  }
}