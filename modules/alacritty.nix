{ config, lib, ... }:
let
  inherit (lib.estera) colorScheme;
  inherit (lib.options) mkEnableOption;
  inherit (config.estera.flake.system) user;

  colors = lib.estera.colorScheme;

  cfg = config.estera.programs.alacritty;
in
{
  options.estera.programs.alacritty = {
    enable = mkEnableOption "alacritty";
  };

  config = lib.modules.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.alacritty = {
        enable = true;
        settings = {

          window = {
            padding = rec {
              x = 0;
              y = x;
            };
          };

          colors = {
            primary = {
              background = colorScheme.bg;
              foreground = colorScheme.fg;
            };

            normal = {
              black = colors.black;
              blue = colors.blue;
              cyan = colors.blue;
              green = colors.green;
              magenta = colors.orange;
              red = colors.red;
              white = colors.fg;
              yellow = colors.yellow;
            };
          };

          font = {
            size = 12.65;
            bold = {
              family = "MonaspiceNe NF";
              style = "Bold";
            };

            italic = {
              family = "MonaspiceNe NF";
              style = "Italic";
            };

            normal = {
              family = "MonaspiceNe NF";
              style = "Retina";
            };
          };
        };
      };
    };
  };
}
