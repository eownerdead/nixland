{ config, lib, dream2nix, ... }:
let cfg = config.service;
in {
  imports = [ ../writeShellApplication.nix ./service.nix ];

  config = {
    name = cfg.name;
    version = "unstable";

    writeShellApplication = with config.deps; {
      name = cfg.name;
      text = with lib; ''
        # ${cfg.description}

        ${cfg.start}
      '';
    };
  };
}
