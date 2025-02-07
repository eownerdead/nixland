{
  lib,
  pkgs,
  ...
}:
{
  options = with lib; {
    services = mkOption {
      type =
        with types;
        attrsOf (submoduleWith {
          modules = [ ../service/service.nix ];
          specialArgs = {
            inherit pkgs;
          };
        });
      default = [ ];
    };
  };
}
