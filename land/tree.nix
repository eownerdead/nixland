# https://github.com/cachix/devenv/blob/7f756cdf3fbb01cab243dcec4de0ca94e6aaa2af/src/modules/files.nix
{
  lib,
  config,
  pkgs,
  land,
  ...
}:
let
  writeExecuting =
    {
      name,
      cmd,
      env ? { },
    }:
    pkgs.writeTextFile {
      name = builtins.baseNameOf name;
      executable = true;
      text =
        ''
          #!${pkgs.runtimeShell}
        ''
        + (lib.concatStrings (
          lib.mapAttrsToList (k: v: ''
            ${lib.toShellVar k v}
            export ${k}
          '') env
        ))
        + ''
          exec ${lib.escapeShellArgs cmd}
        '';
    };

  formats = {
    text = args: {
      type = lib.types.str;
      generate = name: text: pkgs.writeTextFile (args // { inherit name text; });
    };
    exec = args: {
      type = with lib.types; listOf str;
      generate = name: cmd: writeExecuting (args // { inherit name cmd; });
    };
    systemd = { }: pkgs.formats.systemd;
  }; # // pkgs.formats;
in
{
  options = {
    name = lib.mkOption {
      type = lib.types.str;
    };
    tree = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, config, ... }:
          {
            options =
              {
                parm = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                };
                file = lib.mkOption {
                  type = lib.types.path;
                };
              }
              // (lib.mapAttrs (
                _: v:
                lib.mkOption {
                  type = lib.types.nullOr (v { }).type;
                  default = null;
                }
              ) formats);

            config =
              let
                fmtNames = lib.filter (fmt: config.${fmt} != null) (lib.attrNames formats);
                fmtCnt = lib.length fmtNames;
                fmtName =
                  if fmtCnt == 1 then
                    lib.head fmtNames
                  else if fmtCnt > 1 then
                    throw "Multiple formats specified for 'tree.${name}'"
                  else
                    throw "No contents specified for 'tree.${name}'";
              in
              {
                file = (formats.${fmtName} config.parm).generate name config.${fmtName};
              };
          }
        )
      );
    };
    filesScript = lib.mkOption {
      type = lib.types.path;
    };
    out = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = {
    filesScript =
      let
        f = k: v: ''f "${v.file}" "${k}"'';
      in
      pkgs.writeText "${config.name}-files.sh" (
        lib.concatStringsSep "\n" (lib.mapAttrsToList f config.tree)
      );

    out =
      pkgs.runCommand config.name
        {
          preferLocalBuild = true;
        }
        ''
          mkdir "$out"
          cd "$out"

          ${land.deployFiles}/bin/deploy "${config.filesScript}"
        '';
  };
}
