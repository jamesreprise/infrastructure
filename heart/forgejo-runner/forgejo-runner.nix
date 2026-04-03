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
    instances.heart1 = {
      enable = true;
      name = "heart1";
      url = url;
      # file should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      # A label has the following structure:
      # <label-name>:<label-type>://<default-image>
      #
      # The label name is a unique string that identifies the label. It is the part
      # that is specified in the runs-on field of workflows to choose which runners
      # the workflow can be executed on.
      #
      # The label type determines what containerization system will be used to run
      # the workflow. In the case of docker/podman, <default-image> dictates what
      # image will be used when a job specifies 'runs-on: <label-name>' and no
      # container in particular.
      labels = [
        "act-24.04:docker://ghcr.io/catthehacker/ubuntu:act-latest-20260401@sha256:ac990511aa5ce141ad95765f1426a4a3a56feac10b56d85d6a6e7a8893c4ddbe2"
      ];
      settings = {
        log.level = "info";
      };
    };
  };
}
