{
  lib,
  land,
  ...
}:
{
  options = {
    services = lib.mkOption {
      type = lib.types.attrsOf land.types.service;
      default = [ ];
    };
  };
}
