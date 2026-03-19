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
      extraConfig = ''
        proxy_set_header Connection $http_connection;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        client_max_body_size 512M;
      '';
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
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "https://data.forgejo.org";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [forgejoSshPort];
  networking.firewall.allowedUDPPorts = [forgejoSshPort];
}
