let
  primetime = "";
in
{
  "./secrets/deluge.age".publicKeys = [ primetime ];
  "./secrets/unpackerr.age".publicKeys = [ primetime ];
  "./secrets/wireguard.age".publicKeys = [ primetime ];
}
