{ config, lib, dream2nix, ... }:
let cfg = config.service;
in {
  imports = [ ../writeShellApplication.nix ./service.nix ];

  config = {
    name = cfg.name;
    version = "unstable";

    writeShellApplication = with config.deps; {
      name = cfg.name;
      text = with lib;
        ''
          # ${cfg.description}
        '' + lib.optionalString (cfg.env != null) (lib.concatStrings
          (lib.mapAttrsToList (name: value: ''
            ${lib.toShellVar name value}
            export ${name}
          '') cfg.env)) + ''
            ${cfg.start}
          '';
    };
  };
}
