{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      inherit (inputs.nixpkgs) lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./flake-module.nix ];

      systems = [ "x86_64-linux" ];

      flake = {
        flakeModules.default = import ./flake-module.nix;
        lib = import ./lib/default.nix { inherit lib; };
      };

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
              runc
              crun
              youki
              runit
            ];
          };

          land.services = {
            nginx = {
              services.nginx = {
                stateDir = "/var/lib";
                nginx = {
                  enable = true;
                  configFile = "${./nginx.conf}";
                };
              };
            };
          };
        };
    };
}
