{ config, pkgs, ...}:

# A corresponding client config looks like the following:
# ```
# [Interface]
# PrivateKey = ...
# Address = 10.0.0.2/32
# DNS = 1.1.1.1, 1.0.0.1
#
# [Peer]
# PublicKey = ...
# AllowedIPs = 0.0.0.0/0
# EndPoint = ...:51820
# ```

{
  age.secrets.wireguard = {
    file = ./secrets/wireguard.age;
    mode = "500";
    owner = "root";
    group = "root";
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp4s0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.1/24" ];

      listenPort = 51820;
      # This hardcoding is in line with hardware-configuration.nix but probably
      # bad practice. 
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT; ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enp4s0 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT; ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enp4s0 -j MASQUERADE
      '';

      privateKeyFile = config.age.secrets.wireguard.path;

      peers = [
        {
          publicKey = "WkDnFdXZ8BGnTZGd13qzq1V3L30VFL5pdif9IuKi+Wg=";
          allowedIPs = [ "10.0.0.2/32" ];
        }
        {
          publicKey = "pz5+c7AqEBualGXkVx3PWLjuj0eArmpBHSZ+MoIAujQ=";
          allowedIPs = [ "10.0.0.3/32" ];
        }
        {
          publicKey = "xwWHby+0cPhN+K4JQ4uVZELZzf58a2Py5YYt/FDT3Qw=";
          allowedIPs = [ "10.0.0.4/32" ];
        }
      ];
    };
  };
}