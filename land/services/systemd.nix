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

  options.systemd = {
    tree = lib.mkOption {
      type = land.types.tree;
    };
    out.switch = lib.mkOption {
      type = lib.types.package;
    };
  };

  config = {
    systemd = {
      tree = {
        name = "${name}-systemd";
        tree = lib.attrsets.mapAttrs' (
          k: v:
          lib.nameValuePair "${k}.service" {
            systemd = {
              Unit = {
                Description = v.description;
              };
              Service = {
                ExecStart = lib.concatStringsSep " " v.exec;
                Environment = lib.mapAttrsToList (k: v: builtins.toJSON "${k}=${v}") v.env;
              };
            };
          }
        ) config.services;
      };
      out.switch = pkgs.writeShellScriptBin "${name}-switch" ''
        export NIXLAND_SYSTEMD_UNIT_PATH="/run/user/1000/systemd/user"
        export NIXLAND_SYSTEMCTL_ARGS="--user"
        ${land.systemdSwitch}/bin/systemd-switch ${config.systemd.tree.filesScript}
      '';
    };
  };
}
