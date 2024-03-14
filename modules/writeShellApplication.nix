{ config, lib, dream2nix, ... }: {
  imports = with dream2nix.modules.dream2nix; [ package-func deps ];

  options.writeShellApplication = with lib; {
    name = mkOption {
      type = types.str;
      description = "The name of the script to write.";
    };
    text = mkOption {
      type = types.str;
      description = "The shell script's text, not including a shebang.";
    };
    runtimeInputs = mkOption {
      type = with types; listOf (either str package);
      default = [ ];
      description = "Inputs to add to the shell script's `$PATH` at runtime.";
    };
    meta = mkOption {
      type = types.attrs;
      default = { };
      description = "stdenv.mkDerivation`'s `meta` argument.";
    };
    checkPhase = mkOption {
      type = with types; nullOr str;
      default = null;
      description = ''
        The `checkPhase` to run. Defaults to `shellcheck` on supported
        platforms and `bash -n`.

        The script path will be given as `$target` in the `checkPhase`.
      '';
    };
    excludeShellChecks = mkOption {
      type = with types; with types; listOf str;
      default = [ ];
      description = ''
        Checks to exclude when running `shellcheck`, e.g. `[ "SC2016" ]`.

        See <https://www.shellcheck.net/wiki/> for a list of checks.
      '';
    };
  };

  config = {

    deps = { nixpkgs, ... }: { inherit (nixpkgs) writeShellApplication; };

    package-func.result = lib.mkForce (config.deps.writeShellApplication
      (with config.writeShellApplication; {
        inherit name text runtimeInputs meta checkPhase excludeShellChecks;
      }));
  };
}
