# https://github.com/cachix/devenv/blob/e963201a79150f913e4b95be1cfef8c4a301679c/src/modules/services/nginx.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nginx;
  configFile = pkgs.writeText "nginx.conf" ''
    pid ${config.stateDir}/nginx/nginx.pid;
    error_log stderr debug;
    daemon off;

    events {
      ${cfg.eventsConfig}
    }

    http {
      access_log off;
      client_body_temp_path ${config.stateDir}/nginx/;
      proxy_temp_path ${config.stateDir}/nginx/;
      fastcgi_temp_path ${config.stateDir}/nginx/;
      scgi_temp_path ${config.stateDir}/nginx/;
      uwsgi_temp_path ${config.stateDir}/nginx/;

      include ${cfg.defaultMimeTypes};

      ${cfg.httpConfig}
    }
  '';
in
{
  options.nginx = {
    enable = lib.mkEnableOption "nginx";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nginx;
      defaultText = lib.literalExpression "pkgs.nginx";
      description = "The nginx package to use.";
    };

    defaultMimeTypes = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.mailcap}/etc/nginx/mime.types";
      defaultText = lib.literalExpression "\${pkgs.mailcap}/etc/nginx/mime.types";
      example = lib.literalExpression "\${pkgs.nginx}/conf/mime.types";
      description = ''
        Default MIME types for NGINX, as MIME types definitions from NGINX are very incomplete,
        we use by default the ones bundled in the mailcap package, used by most of the other
        Linux distributions.
      '';
    };

    httpConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "The nginx configuration.";
    };

    eventsConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "The nginx events configuration.";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      default = configFile;
      internal = true;
      description = "The nginx configuration file.";
    };
  };

  config = lib.mkIf cfg.enable {
    description = "";
    exec = [
      "${cfg.package}/bin/nginx"
      "-c"
      "${cfg.configFile}"
      "-e"
      "/dev/stderr"
    ];
  };
}
