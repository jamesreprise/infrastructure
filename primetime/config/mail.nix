{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.mailutils ];

  services.postfix.enable = true;
}

