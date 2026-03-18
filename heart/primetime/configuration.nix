{ modulesPath, pkgs, ... }:

let 
  rootSshPubKeys = ["..."];
in {
  imports = [
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
    # Auto-generated
    ./incus.nix
    ./content.nix
  ];

  networking = {
    hostName = "primetime";
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
    firewall.allowedUDPPorts = [ 5201 ];
    firewall.allowedTCPPorts = [ 5201 ];
  };

  systemd.network = {
    enable = true;
    networks."50-enp5s0" = {
      matchConfig.Name = "enp5s0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = rootSshPubKeys;
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "without-password";
      PasswordAuthentication = false;
    };
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = with pkgs; [ vim ];

  environment.etc.issue.text = ''
    I thought that my voyage had come to its end at the last limit of my power,
    —that the path before me was closed, that provisions were exhausted and the
    time come to take shelter in a silent obscurity.

    But I find that thy will knows no end in me. And when old words die out on
    the tongue, new melodies break forth from the heart; and where the old
    tracks are lost, new country is revealed with its wonders.

    Rabindranath Tagore


  '';

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "26.05";
}
