{ lib, ... }:
{
  service =
    with lib;
    types.submodule {
      options = {
        name = mkOption { type = types.str; };
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
    };
}
