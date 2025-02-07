{ lib, ... }:
{
  imports = [ ./nginx.nix ];

  options = with lib; {
    description = mkOption {
      type = types.str;
      default = "";
    };
    env = mkOption {
      type = types.attrs;
      default = { };
    };
    exec = mkOption { type = with types; listOf str; };
    stateDir = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };
}
