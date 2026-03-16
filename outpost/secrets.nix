let
  outpost-1 = "ssh-ed25519 ...";
  systems = [ outpost-1 ];
in
{
  "./secrets/wireguard.private-key.age".publicKeys = systems;
}
