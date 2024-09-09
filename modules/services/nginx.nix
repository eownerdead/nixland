{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nginx;
in
{
  imports = [
    ../service/shellScript.nix
    ../service/ociBundle.nix
    ../service/service.nix
    # ../service/oci.nix
  ];

  options.services.nginx = with lib; {
    package = mkOption {
      type = types.package;
      default = pkgs.nginx;
    };
    configFile = mkOption {
      type = with types; either path str;
      description = "The nginx configuration file.";
    };
  };

  config.service = {
    name = "nginx";
    description = "";
    exec = [
      "${cfg.package}/bin/nginx"
      "-p"
      "${config.service.stateDir}"
      "-c"
      "${cfg.configFile}"
      "-e"
      "/dev/stderr"
    ];
  };
}
