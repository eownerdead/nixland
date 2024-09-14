{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ../service/service.nix ];

  options.bin = with lib; {
    path = mkOption { type = with types; nullOr package; };
    packages = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
  };

  config = {
    packages = [ config.bin.path ];

    bin.path = pkgs.buildEnv {
      name = "bin";
      paths = config.bin.packages;
      pathsToLink = [ "/bin" ];
    };
  };
}
