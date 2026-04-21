{ pkgs, ...}:

let
  port = 4430;
in {
  services.foundationdb = {
    enable = true;
    package = pkgs.foundationdb;
  };

  environment.systemPackages = with pkgs; [ foundationdb ];

  networking.firewall.allowedTCPPorts = [port];
  networking.firewall.allowedUDPPorts = [port];
}
