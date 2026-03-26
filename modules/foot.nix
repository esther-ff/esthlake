{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib.estera) colorScheme;
  inherit (lib.modules) mkIf;
  inherit (lib) removePrefix mapAttrs;

  cfg = config.estera.programs.foot;
in
{
  options.estera.programs.foot.enable = mkEnableOption "foot";

  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        main = {
          font = "MonaspiceNe NF:size=12";
          shell = "${pkgs.fish}/bin/fish";
        };

        colors-dark =
          let
            inherit (colorScheme)
              bg
              fg
              white
              black
              red
              yellow
              green
              blue
              aqua
              orange
              ;
          in
          mapAttrs (name: value: removePrefix "#" value) rec {
            background = bg;
            foreground = fg;

            regular0 = black; # black
            regular1 = red; # red
            regular2 = green; # green
            regular3 = yellow; # yellow
            regular4 = blue; # blue
            regular5 = orange; # magenta
            regular6 = aqua; # cyan
            regular7 = white; # white

            bright0 = regular0; # bright black
            bright1 = regular1; # bright red
            bright2 = regular2; # bright green
            bright3 = regular3; # bright yellow
            bright4 = regular4; # bright blue
            bright5 = regular5; # bright magenta
            bright6 = regular6; # bright cyan
            bright7 = regular7; # bright white
          };
      };
    };
  };
}
