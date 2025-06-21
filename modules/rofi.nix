{ config, lib, pkgs, ... }:
let
  cfg = config.estera.programs.rofi;
  inherit (lib.options) mkEnableOption;
in {
  options.estera.programs.rofi = { enable = mkEnableOption "rofi"; };

  config = lib.modules.mkIf cfg.enable {
    # programs.rofi = {
    # enable = true;
    #   font = "FiraCode 14";
    #   location = "center";
    #   package = pkgs.rofi-wayland;
    #   # modes = [ "drun" ];

    #   theme = let
    #     inherit (config.lib.formats.rasi) mkLiteral;
    #     background = "#140e07";
    #     foreground = "#f09ac7";
    #   in {
    #     "*" = {
    #       background-color = mkLiteral background;
    #       foreground-color = mkLiteral foreground;
    #       border-color = mkLiteral "rgba( 181, 134, 232, 100 %)";
    #     };
    #   };

    #   terminal = "alacritty";

    # };

  };
}
