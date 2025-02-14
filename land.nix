{
  pkgs ? <nixpkgs>,
  lib ? pkgs.lib,
  ...
}:
let
  land = {
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
