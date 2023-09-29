{ config, pkgs, lib, ... }:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "localhost";
        root_url = "%(protocol)s://%(domain)s/grafana/";
        serve_from_sub_path = true;
        http_addr = "127.0.0.1";
        http_port = 3000;
      };
      "auth.anonymous" = {
        enabled = true;
        org_name = "Primetime";
        org_role = "Viewer";
      };
      "plugin.marcusollson-csv-datasource" = {
        allow_local_mode = true;
      };
    };
  };

  services.prometheus = {
    enable = true;
    enableReload = true;
    scrapeConfigs = [
      {
        job_name = "pushgateway eustonwall";
        honor_labels = true;
        scrape_interval = "5s";
        static_configs = [ { targets = [ "localhost:9091" ]; }];
      }
    ];
  };

  services.prometheus.pushgateway = {
    enable = true;
    log.level = "debug";
  };
}

