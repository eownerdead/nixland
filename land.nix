{
  pkgs ? <nixpkgs>,
  lib ? pkgs.lib,
  ...
}:
let
  land = {
    deployFiles = pkgs.writeShellScriptBin "deploy" ''
      set -eu

      f() {
        if [ -L "$2" ]
        then
          echo "$1 -> $2 (overwrite)"
        elif [ -e "$2" ]
        then
          echo "error: Non-symbolic link file $2 already exit"
        else
          echo "$1 -> $2"
        fi

        mkdir -p `dirname $2`
        ln -sf "$1" "$2"
      }

      . "$1"
    '';

    cleanFiles = pkgs.writeShellScriptBin "clean" ''
      set -eu

      f() {
        if [ -L "$2" ]
        then
          echo "rm $2"
          rm "$2"
        elif [ -e "$2" ]
          echo "File $2 is not a symbolic link"
        fi
      }

      . "$1"
    '';

    systemdSwitch = pkgs.writeShellScriptBin "systemd-switch" ''
      set -eu

      mkdir -p "$NIXLAND_SYSTEMD_UNIT_PATH"
      cd "$NIXLAND_SYSTEMD_UNIT_PATH"
      ${land.deployFiles}/bin/deploy "$1"

      systemctl "$NIXLAND_SYSTEMCTL_ARGS" daemon-reload

      f() {
        systemctl "$NIXLAND_SYSTEMCTL_ARGS" start `basename "$2"`
      }

      . "$1"
    '';

    types = {
      tree = lib.types.submoduleWith {
        modules = [ ./land/tree.nix ];
        specialArgs = {
          inherit pkgs land;
        };
        class = "tree";
      };
      service = lib.types.submoduleWith {
        modules = [ ./land/service.nix ];
        specialArgs = {
          inherit pkgs land;
        };
        class = "service";
      };
      services = lib.types.submoduleWith {
        modules = [ ./land/services.nix ];
        specialArgs = {
          inherit pkgs land;
        };
        class = "services";
      };
    };
  };
in
land
