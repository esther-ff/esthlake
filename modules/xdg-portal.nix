{ config, pkgs, lib, ... }:
let
  cfg = config.estera.programs.xdg-portal;
  inherit (lib.options) mkEnableOption;
in {
  options.estera.programs.xdg-portal = {
    enable = mkEnableOption "xdg-portal";
  };

  config = lib.modules.mkIf cfg.enable {
    xdg = {
      portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal ];
        config = { common.default = "*"; };
      };
    };
  };
}
