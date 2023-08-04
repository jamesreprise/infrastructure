{ config, pkgs, ... }:

{
    services.nginx = {
        enable = true;
        enableReload = true;
        recommendedTlsSettings = true;
    };

    services.nginx.virtualHosts."requests.localhost" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:5055";
        };
    };

    services.nginx.virtualHosts."localhost" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/primetime";
        locations."/".extraConfig = ''
          index index.txt;
        '';
        locations."/grafana/" = {
          recommendedProxySettings = true;
          proxyPass = "http://localhost:3000";
          proxyWebsockets = true;
       };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "admin@localhost";
    };

    networking.firewall = {
        allowedTCPPorts = [ 80 443 ];
    };
}

