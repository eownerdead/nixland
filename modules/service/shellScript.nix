{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.service;
in
{
  imports = [ ./service.nix ];

  options.out.app = lib.mkOption { type = lib.types.package; };

  config.out.app = pkgs.writeScriptBin (cfg.name + "-app") (
    ''
      # ${cfg.description}
    ''
    + lib.concatStrings (
      lib.mapAttrsToList (name: value: ''
        ${lib.toShellVar name value}
        export ${name}
      '') cfg.env
    )
    + (lib.escapeShellArgs cfg.exec)
  );
}
