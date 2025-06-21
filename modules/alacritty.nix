{ config, lib, ... }:
let
  inherit (lib.estera) colorPicker colorScheme;
  inherit (lib.options) mkEnableOption;
  inherit (config.estera.flake.system) user;

  cfg = config.estera.programs.alacritty;
in {
  options.estera.programs.alacritty = { enable = mkEnableOption "alacritty"; };

  config = lib.modules.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.alacritty = {
        enable = true;
        settings = {

          window = {
            padding = rec {
              x = 5;
              y = x;
            };
          };

          colors = {
            primary = {
              background = colorScheme.bg;
              foreground = colorScheme.fg;
            };

            normal = {
              black = colorPicker 1;
              blue = colorPicker 1;
              cyan = colorPicker 2;
              green = colorPicker 3;
              magenta = colorPicker 4;
              red = colorPicker 5;
              white = colorPicker 6;
              yellow = colorPicker 7;
            };
          };

          font = {
            bold = {
              family = "Fira Code";
              style = "Bold";
            };

            italic = {
              family = "Fira Code";
              style = "Italic";
            };

            normal = {
              family = "Fira Code";
              style = "Retina";
            };
          };
        };
      };
    };
  };
}

