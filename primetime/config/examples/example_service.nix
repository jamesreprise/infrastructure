{ config, lib, pkgs, ...}:

{
  users.users.minecraft = {
    isNormalUser = true;
    home = "/home/minecraft";
    group = "minecraft";
    hashedPassword = "...";
  };
  users.groups.minecraft = {};

  systemd.services.minecraft = {
    enable = true;
    description = "Minecraft server";
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      WorkingDirectory = "...";
      ExecStart = "${pkgs.jdk8}/bin/java -server -Xms16G -Xmx32G -XX:SurvivorRatio=4 -XX:InitialSurvivorRatio=1 -XX:NewRatio=4 -XX:MaxTenuringThreshold=12 -XX:+DisableExplicitGC -Dfml.doNotBackup=true -Dfml.readTimeout=65500 -Dfml.loginTimeout=65500 -jar ... nogui";
      User = "minecraft";
      Group = "minecraft";
    };
    wantedBy = [ "multi-user.target" ];
  };
}