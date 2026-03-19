{ pkgs, ...}:

let
  domainName = "example";
  forgejoHttpPort = 3000;
  forgejoSshPort = 2222;
in {
  services.nginx.virtualHosts.${domainName} = {
    enableACME = true;
    forceSSL = true;
    serverName = domainName;
    locations."/" = {
      proxyPass = "http://localhost:${toString forgejoHttpPort}";
    };
  };

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    settings = {
      server = {
        DOMAIN = domainName;

        HTTP_PORT = forgejoHttpPort;

        START_SSH_SERVER = true;
        SSH_PORT = forgejoSshPort;
        SSH_LISTEN_PORT = forgejoSshPort;

        ROOT_URL = "https://${domainName}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [forgejoSshPort];
  networking.firewall.allowedUDPPorts = [forgejoSshPort];
}
