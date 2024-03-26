{ config, lib, dream2nix, ... }: {
  options.service = with lib; {
    name = mkOption { type = types.str; };
    description = mkOption {
      type = types.str;
      default = "";
    };
    backend = mkOption { type = types.str; };
    env = mkOption {
      type = types.attrs;
      default = { };
    };
    start = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };
}
