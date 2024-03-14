{ config, lib, dream2nix, ... }:
let cfg = config.services.firefox;
in {
  imports = [
    dream2nix.modules.dream2nix.mkDerivation
    ../service/service.nix
    ../service/shellScript.nix
  ];

  options.services.firefox = with lib; {
    stateDir = mkOption { type = with types; either path str; };
    package = mkOption { type = with types; nullOr package; };
  };

  config = {
    deps = { nixpkgs, ... }: { inherit (nixpkgs) firefox; };

    name = "firefox";
    version = "unstable";

    service = {
      name = "firefox";
      env = { HOME = cfg.stateDir; };
      start = "${config.deps.firefox}/bin/firefox";
    };
  };
}
