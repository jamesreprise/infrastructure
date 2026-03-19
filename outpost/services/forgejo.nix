{ pkgs, ...}:

let
  domainName = "example";
  forgejoHttpPort = 3000;
  forgejoSshPort = 2222;
in {
  services.nginx.virtualHosts."git" = {
    enableACME = true;
    forceSSL = true;
    serverName = "git.${domainName}";
    locations."/" = {
      proxyPass = "http://localhost:${forgejoHttpPort}";
    };
  };

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    settings = {
      server = {
        HTTP_PORT = forgejoHttpPort;
        SSH_PORT = forgejoSshPort;
        DOMAIN = domainName;
      };
    };
  };

  environment.systemPackages = with pkgs; [ forgejo-cli ];
}
