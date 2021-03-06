{ config, lib, substituteAll, xdg_utils }:

let
  inherit (config.environment.hidpi) scale;
  inherit (config.environment) colors;
in

substituteAll (colors.hex // {
  src = ../../data/config/dunst/dunstrc;

  # TODO: Fix it to treat negative x correctly
  geometry = let
    width = toString (450 * scale);
    height = toString 5;
    d = x:
    "${if x >= 0 then "+" else ""}${toString (x * scale)}";
    # 23 is derived from [bspwm window gap: 60] / (1 + [phi: 1.618])
  in "${width}x${height}${d (- 23)}${d (46 - 4)}";

  padding = toString (3 * scale);

  horizontal_padding = toString (5 * scale);

  frame_width = toString (3 * scale);

  min_icon_size = toString (36 * scale);

  icon_path = let
    s = toString (24 * scale);
    path = "/run/current-system/sw/share/icons/oomox-default";
  in lib.concatStringsSep ":"
  (map (c: "${path}/${s}x${s}/${c}") [ "status" "devices" "apps" ]);

  browser = "${xdg_utils}/bin/xdg-open";
})
