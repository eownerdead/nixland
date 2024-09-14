_: {
  imports = [
    ./bin/bin.nix

    ./service/service.nix
    ./service/ociBundle.nix
    ./service/shellScript.nix

    ./services/nginx.nix
  ];
}
