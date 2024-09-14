{ lib, config, ... }:
{
  options = with lib; {
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
    packages = mkOption { type = with types; listOf package; };
    stateDir = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  config.env.PATH = lib.makeBinPath config.packages;
}
