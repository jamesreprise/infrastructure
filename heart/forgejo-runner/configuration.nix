{ modulesPath, pkgs, ... }:

let
  rootSshPubKeys = ["..."];
  hostName = "forgejo-runner";
in {
  imports = [
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
    # Auto-generated
    ./incus.nix

    ./forgejo-runner.nix
  ];

  networking = {
    hostName = hostName;
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
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

  environment.etc.issue.text = "";

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "26.05";
}
