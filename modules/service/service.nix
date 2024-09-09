{ lib, land, ... }:
{
  options.service = lib.mkOption { type = land.types.service; };
}
