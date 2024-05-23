{ defaultUsername }:
{ lib, ... }:
{
  options.username = lib.mkOption {
    type = lib.types.str;
    default = defaultUsername;
  };
}