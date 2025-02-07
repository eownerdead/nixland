{
  name,
  config,
  lib,
  pkgs,
  land,
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
      tree = lib.mkOption {
        type = land.types.tree;
      };
      out.start = lib.mkOption { type = lib.types.package; };
    };
  };

  config = {
    runit = {
      tree = {
        name = name;
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
      out.start = pkgs.writeShellScriptBin "${name}-start" ''
        mkdir -p "$SVDIR"
        cd "$SVDIR"
        ${config.runit.tree.scriptFile}

        exec ${config.runit.package}/bin/runsvdir "$SVDIR"
      '';
    };
  };
}
