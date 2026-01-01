{ config, pkgs, ...}:

# A corresponding client config looks like the following:
# ```
# [Interface]
# PrivateKey = ...
# Address = 10.128.64.2/32
# DNS = 1.1.1.1, 1.0.0.1
#
# [Peer]
# PublicKey = ...
# AllowedIPs = 0.0.0.0/0
# EndPoint = ...:51820
# ```

{
  age.secrets.wireguard = {
    file = ./secrets/wireguard.private-key.age;
    mode = "640";
    owner = "systemd-network";
    group = "systemd-network";
  };

  # Following https://wiki.nixos.org/wiki/WireGuard#systemd.network
  networking.useNetworkd = true;
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };
  networking.nat = {
    enable = true;
    externalInterface = "ens3";
    internalInterfaces = [ "wg0" ];
  };

  systemd.network = {
    enable = true;

    networks."50-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.128.64.1/32" ];
      networkConfig = {
        IPv4Forwarding = true;
      };
    };

    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        ListenPort = 51820;
        PrivateKeyFile = config.age.secrets.wireguard.path;
        RouteTable = "main";
        FirewallMark = 42;
      };
      wireguardPeers = [{
        PublicKey = "OwB+PBUS0ckNV8eD2o8ChlM1ZLnuGSGqtf5nzReP6zM=";
        AllowedIPs = [ "10.128.64.2/32" ];
      }];
    };
  };
}
