{ config, lib, substituteAll, termite }:

let
  inherit (config.environment.hidpi) scale;
  colortheme = lib.mapAttrs (_: c: c.hex) config.environment.colortheme.palette;
in

substituteAll (colortheme // {
  src = ../../data/config/rofi/config.rasi;

  dpi = toString (96 * scale);

  font = "Source Code Pro Medium 13";

  terminal = "${termite}/bin/termite";
})
