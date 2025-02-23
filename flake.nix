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

      debug = true;

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

          legacyPackages = import ./land.nix { inherit pkgs; };

          land.services = {
            test = {
              services = {
                nginx = rec {
                  stateDir = "/home/noobuser/src/nixland";
                  nginx = {
                    enable = true;
                    httpConfig = ''
                      server {
                        listen 8080;
                        server_name localhost;

                        location / {
                          root ${stateDir};
                          autoindex on;
                        }
                      }
                    '';
                  };
                };
                ollama = {
                  stateDir = "/home/noobuser/src/nixland/ollama";
                  ollama.enable = true;
                };
              };
            };
          };
        };
    };
}
