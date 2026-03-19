{ pkgs, config, ... }:

let
  url = "example";
in {
  age.secrets.forgejo-runner-token = {
    file = ../secrets/forgejo-runner-token.age;
    mode = "640";
  };

  virtualisation.podman.enable = true;

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.heart-1 = {
      enable = true;
      name = "heart-1";
      url = url;
      # file should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      labels = [
        "ubuntu-22.04:docker://node:16-bullseye"
      ];
    };
  };
}
