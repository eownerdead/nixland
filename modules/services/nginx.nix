{ config, lib, dream2nix, ... }:
let cfg = config.services.nginx;
in {
  imports = [
    dream2nix.modules.dream2nix.mkDerivation
    ../service/service.nix
    ../service/shellScript.nix
  ];

  options.services.nginx = with lib; {
    stateDir = mkOption { type = with types; either path str; };
    configFile = mkOption {
      type = with types; either path str;
      description = "The nginx configuration file.";
    };
  };

  config = {
    deps = { nixpkgs, ... }: { inherit (nixpkgs) nginx; };

    name = "nginx";
    version = "unstable";

    service = {
      name = "nginx";
      start = ''
        ${config.deps.nginx}/bin/nginx \
          -p '${cfg.stateDir}' \
          -c '${cfg.configFile}' \
          -e /dev/stderr
      '';
    };
  };
}
