{ config, pkgs, ...}:

{
  services.foundationdb = {
    enable = true;
    package = pkgs.foundationdb;
  };

  environment.systemPackages = with pkgs; [ foundationdb ];
}
