{ config, pkgs, lib, ... }:

{
  # Plex
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "plexmediaserver" ];
  services.plex.enable = true;
  services.plex.openFirewall = true;
  users.users."${config.services.plex.user}".extraGroups = [ "deluge" "radarr" "sonarr" "unpackerr" ];

  # Ombi
  services.ombi.enable = true;
  services.ombi.openFirewall = true;

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
  };
  users.users.unpackerr.extraGroups = [ "deluge" "radarr" "sonarr" ];

  age.secrets.unpackerr = {
    file = ./secrets/unpackerr.age;
    mode = "500";
    owner = "unpackerr";
    group = "unpackerr";
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
  services.deluge.declarative = true;
  services.deluge.enable = true;
  services.deluge.openFirewall = true;
  
  services.deluge.web.enable = true;

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

  age.secrets.deluge = {
    file = ./secrets/deluge.age;
    mode = "500";
    owner = config.services.deluge.user;
    group = config.services.deluge.group;
  };

  services.deluge.authFile = config.age.secrets.deluge.path;
  services.deluge.config = {
    allow_remote = true;

    download_location = "/opt/downloads/downloading";
    move_completed = true;
    move_completed_path = "/opt/downloads/complete";
    copy_torrent_file = true;
    torrentfiles_location = "/opt/downloads/torrent_files";

    enabled_plugins = [ "Execute" "Label" ];

    max_active_seeding = "-1";
    max_active_downloading = "-1";
    max_active_limit = "-1";
    stop_seed_at_ratio = false;
    remove_seed_at_ratio = false;

    max_connections = "-1";
    max_upload_speed = "-1.0";
    max_download_speed = "-1.0";
    max_upload_slots_global = "-1";
    seed_time_limit = "-1";

    dht = false;
    natpmp = false;
    utpex = false;
    upnp = false;
    lsd = false;
  };
}