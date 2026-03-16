{ config, pkgs, ...}:

let
  domainName = "example";
in {
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    settings = {
      server = {
        PROTOCOL = "https";
        SSH_PORT = 2222;
        DOMAIN = domainName;

        ROOT_URL = "${config.services.forgejo.settings.server.PROTOCOL}://${domainName}:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}";

        CERT_FILE = "${config.security.acme.certs.${domainName}.directory}/fullchain.pem";
        KEY_FILE = "${config.security.acme.certs.${domainName}.directory}/key.pem";
      };
    };
  };

  environment.systemPackages = with pkgs; [ forgejo-cli ];

  networking.firewall = {
    allowedTCPPorts = [ config.services.forgejo.settings.server.HTTP_PORT ];
  };

  security.acme = {
    certs."${domainName}" = {
      listenHTTP = ":80";
      group = config.services.forgejo.group;
    };
  };
}
