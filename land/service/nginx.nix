{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nginx;
in
{
  options.nginx = with lib; {
    enable = mkEnableOption "";
    package = mkOption {
      type = types.package;
      default = pkgs.nginx;
    };
    configFile = mkOption {
      type = with types; either path str;
      description = "The nginx configuration file.";
    };
  };

  config = lib.mkIf cfg.enable {
    description = "";
    exec = [
      "${cfg.package}/bin/nginx"
      "-p"
      "${config.stateDir}"
      "-c"
      "${cfg.configFile}"
      "-e"
      "/dev/stderr"
    ];
  };
}
