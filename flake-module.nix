{ flake-parts-lib, lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { pkgs, config, ... }:
    let
      land = import ./land.nix { inherit pkgs; };
    in
    {
      options.land = {
        services = lib.mkOption {
          default = { };
          type = lib.types.attrsOf land.types.services;
        };
      };

      config.packages = lib.mapAttrs (_: v: v.systemd.out.switch) config.land.services;
    }
  );
}
