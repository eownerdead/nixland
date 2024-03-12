{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    utils.url = "github:numtide/flake-utils";
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, dream2nix }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in rec {
        formatter = pkgs.nixfmt;

        packages.nginx-example = dream2nix.lib.evalModules {
          packageSets.nixpkgs = pkgs;
          modules = [
            ./modules/services/nginx.nix
            {
              services.nginx = {
                configFile = ./nginx.conf;
                stateDir = "/home/noobuser/src/nixland";
              };
            }
          ];
        };

        apps.nginx-example = {
          type = "app";
          program = "${packages.nginx-example}/bin/nginx";
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ editorconfig-checker nixfmt ];
        };
      });
}
