{ config, pkgs, lib, ... }:

{
  users.users.james.extraGroups = ["deluge" "radarr" "sonarr" "unpackerr" "plex"];

  # Secrets
  age.secrets.deluge = {
    file = ./secrets/deluge.age;
    mode = "500";
    owner = config.services.deluge.user;
    group = config.services.deluge.group;
  };

  age.secrets.unpackerr = {
    file = ./secrets/unpackerr.age;
    mode = "500";
    owner = "unpackerr";
    group = "unpackerr";
  };

  # Jellyfin
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Ombi
  services.ombi = {
    enable = true;
    openFirewall = true;
  };

  # Overseerr
  virtualisation.oci-containers.containers."overseerr" = {
    image = "sctx/overseerr:latest";
    ports = [ "5055:5055" ];
    volumes = [ "/opt/overseerr/config:/app/config" ];
  };

  # Jackett
  services.jackett.enable = true;

  # Radarr
  services.radarr.enable = true;
  users.users."${config.services.radarr.user}".extraGroups = [ "deluge" "unpackerr" ];

  # Sonarr
  services.sonarr.enable = true;
  users.users."${config.services.sonarr.user}".extraGroups = [ "deluge" "unpackerr" ];

  # Unpackerr
  environment.systemPackages = [ pkgs.unpackerr ];
  users.groups.unpackerr = {};
  users.users.unpackerr = {
    isSystemUser = true;
    group = "unpackerr";
    extraGroups = [ "deluge" "radarr" "sonarr" ];
  };
  
  systemd.services.unpackerr = {
    enable = true;
    description = "unpackerr service for Radarr and Sonarr";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "unpackerr";
      Group = "unpackerr";
      ExecStart = "${pkgs.unpackerr}/bin/unpackerr -c ${config.age.secrets.unpackerr.path}";
    };
  };

  # Deluge
  services.deluge = {
    enable = true;
    openFirewall = true;
    web = {
        enable = true;
    };
        
    authFile = config.age.secrets.deluge.path;
    config = {
        allow_remote = true;

        download_location = "/opt/downloads/downloading";
        move_completed = true;
        move_completed_path = "/opt/downloads/complete";
        copy_torrent_file = true;
        torrentfiles_location = "/opt/downloads/torrent_files";

        enabled_plugins = [ "Execute" "Label" ];

        max_active_seeding = -1;
        max_active_downloading = -1;
        max_active_limit = -1;
        stop_seed_at_ratio = false;
        remove_seed_at_ratio = false;

        max_connections_global = -1;
        max_connections_per_torrent = -1;
        max_connections_per_second = -1;
        max_half_open_connections = -1;
        max_upload_speed = -1.0;
        max_download_speed = -1.0;
        max_upload_slots_global = -1;
        seed_time_limit = -1;

        dht = false;
        natpmp = false;
        utpex = false;
        upnp = false;
        lsd = false;
    };
  };

  environment.etc."deluge/chmod.sh" = {
    enable = true;
    text = ''
      #!/bin/bash
      torrentid=$1
      torrentname=$2
      torrentpath=$3
      chmod -R 770 "$torrentpath"
    '';
    mode = "0555";
  };
}