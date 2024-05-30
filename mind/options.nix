{ defaultUsername, defaultFullName, defaultEmail }:
{ lib, ... }:
{
  options.username = lib.mkOption {
    type = lib.types.str;
    default = defaultUsername;
  };
  options.fullName = lib.mkOption {
    type = lib.types.str;
    default = defaultFullName;
  };
  options.email = lib.mkOption {
    type = lib.types.str;
    default = defaultEmail;
  };
}
