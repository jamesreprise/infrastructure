{ config, pkgs, ...}:
{
  age.secrets.wireguard = {
    file = ../secrets/wireguard.private-key.age;
    mode = "640";
    owner = "systemd-network";
    group = "systemd-network";
  };

  networking = {
    useNetworkd = true;
    firewall = {
      allowedUDPPorts = [ 51820 ];
    };
    nat = {
      enable = true;
      externalInterface = "enp5s0";
      internalInterfaces = [ "wg0" ];
    };
  };

  systemd.network = {
    networks."60-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "10.128.64.28/30" ];
      networkConfig = {
        IPv4Forwarding = true;
      };
    };

    netdevs."60-wg0" = {
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
      wireguardPeers = [
        {
          PublicKey = "...";
          AllowedIPs = [ "10.128.64.28/30" ];
          PersistentKeepalive = 10;
        }
      ];
    };
  };
}
