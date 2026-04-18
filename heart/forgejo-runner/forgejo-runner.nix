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
        "nix:docker://registry.hub.docker.com/nixos/nix:2.34.4@sha256:446804c0005967290a3ef8c70f7f7739289cea43e365c3fc10ad1427f85fcd5c"
        "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:runner-24.04@sha256:8b8b937266610507a6bfbd7c53aefa5ee38b9c1562e4b08e516c0afe8be09f51"
        "bazel:docker://git.berserk.dev/berserksystems/bazelisk@sha256:d2db0bb5952872e239a164a5b24a5f6e4c6dc46d3f0dab4a672c4b88f084708b"
      ];
      settings = {
        log.level = "info";
        cache = {
          enabled = true;
          host = "host.containers.internal";
        };
        container.network = "host";
      };
    };
  };
}
