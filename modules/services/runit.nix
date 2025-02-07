{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./services.nix ];

  options = {
    runit = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.runit;
      };
      dir = lib.mkOption {
        type = lib.types.submoduleWith {
          modules = [ ../files.nix ];
          specialArgs = {
            inherit pkgs;
          };
        };
      };
    };
    out.app = lib.mkOption { type = lib.types.package; };
  };

  config = {
    runit.dir = {
      name = "services";
      tree = lib.attrsets.mapAttrs' (
        k: v:
        lib.nameValuePair "${k}/run" {
          parm = {
            inherit (v) env;
          };
          exec = v.exec;
        }
      ) config.services;
    };
    out.app = pkgs.writeShellScriptBin "run" ''
      mkdir -p "$SVDIR"
      cd "$SVDIR"
      ${config.runit.dir.scriptFile}

      exec ${config.runit.package}/bin/runsvdir "$SVDIR"
    '';
  };
}
