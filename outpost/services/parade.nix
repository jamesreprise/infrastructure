{ pkgs, ...}:

let
  domainName = "parade.berserk.dev";
  port = 4430;
in {
  services.foundationdb = {
    enable = true;
    package = pkgs.foundationdb;
  };

  environment.systemPackages = with pkgs; [ foundationdb ];

  services.nginx.virtualHosts.${domainName} = {
    serverName = domainName;
    locations."/" = {
      proxyPass = "https://localhost:${toString port}";
    };
  };
}
