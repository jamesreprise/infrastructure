let
  forgejo-runner = "ssh-ed25519 ...";
  systems = [ forgejo-runner ];
in
{
  "./secrets/forgejo-runner-token.age".publicKeys = systems;
}
