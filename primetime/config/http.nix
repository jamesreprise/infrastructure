{ config, pkgs, ... }:

# WIP
{
    # This seems to create a situation where nginx doesn't respond to any
    # requests. It should at least load the default status page. Setting
    # the relevant flag for that doesn't do anything.

    # It's possible there is an expectation that you implement a fully TLS 
    # certificate-enabled setup before working correctly. 
    services.nginx = {
        enable = true;
        enableReload = true;
    };

    services.nginx.virtualHosts."primetime.james.gg" = {
        root = "/var/www/primetime";
    };
}