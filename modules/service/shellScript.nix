{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./service.nix ];

  options.out.app = lib.mkOption { type = lib.types.package; };

  config.out.app = pkgs.writeScriptBin (config.name + "-app") (
    ''
      # ${config.description}
    ''
    + lib.concatStrings (
      lib.mapAttrsToList (name: value: ''
        ${lib.toShellVar name value}
        export ${name}
      '') config.env
    )
    + (lib.escapeShellArgs config.exec)
  );
}
