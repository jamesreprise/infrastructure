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
        "alpine:docker://alpine:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659"
      ];
    };
  };
}
