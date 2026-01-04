{ config, pkgs, ...}:

{
  networking.firewall.allowedTCPPorts = [ 80 ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      server = "https://acme-v02.api.letsencrypt.org/directory";
      email = "example";
    };
    certs."example" = {
      listenHTTP = ":80";
    };
  };
}
