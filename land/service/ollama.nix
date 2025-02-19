# https://github.com/NixOS/nixpkgs/blob/c618e28f70257593de75a7044438efc1c1fc0791/nixos/modules/services/misc/ollama.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ollama;
in
{
  options.ollama = {
    enable = lib.mkEnableOption "ollama";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ollama;
      defaultText = lib.literalExpression "pkgs.ollama";
      description = "The ollama package to use.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "[::]";
      description = ''
        The host address which the ollama server HTTP interface listens to.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      example = 11111;
      description = ''
        Which port the ollama server listens to.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    description = "";
    exec = [
      "${cfg.package}/bin/ollama"
      "serve"
    ];
    env = {
      OLLAMA_MODELS = config.stateDir;
      OLLAMA_HOST = "${cfg.host}:${builtins.toString cfg.port}";
    };
  };
}
