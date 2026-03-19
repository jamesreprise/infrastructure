{ ... }:

{
  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedTlsSettings = true;
  };
}
