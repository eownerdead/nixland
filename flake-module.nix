{ flake-parts-lib, lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { pkgs, config, ... }:
    {
      options.land = {
        apps = lib.mkOption {
          default = { };
          type = lib.types.lazyAttrsOf (
            lib.types.submoduleWith {
              modules = [ ./modules/top-level.nix ];
              specialArgs = {
                inherit pkgs;
                land = import ./lib/default.nix { inherit lib; };
              };
            }
          );
        };
      };

      config.apps = lib.mapAttrs (k: v: {
        program = v.out.app;
        type = "app";
      }) config.land.apps;
    }
  );
}
