{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
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
              editorconfig-checker
              nixfmt-rfc-style
              runc
              crun
              youki
            ];
          };

          land.services.nginx = {
            service.stateDir = "/var/lib";
            ociBundle.stateDir = "/home/noobuser/src/nixland/nginx";
            services.nginx = {
              configFile = "${./nginx.conf}";
            };
          };
        };
    };
}
