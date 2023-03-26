{ config, pkgs, ... }:

# WIP - need to provide all the info for SSL
{
    services.nginx = {
        enable = true;
        enableReload = true;
    };

    services.nginx.virtualHosts."primetime.james.gg" = {
        root = "/var/www/primetime";
    };

    networking.firewall = {
        allowedTCPPorts = [ 80 ];
    };
}