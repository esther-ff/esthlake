{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.estera.programs.xdg-portal;
  inherit (lib.options) mkEnableOption;
in
{
  options.estera.programs.xdg-portal = {
    enable = mkEnableOption "xdg-portal";
  };

  config = lib.modules.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome-session
      nautilus
    ];
    xdg = {
      portal = {
        xdgOpenUsePortal = true;
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config.niri = {
          default = [
            "gtk"
            "gnome"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        };
      };
    };
  };
}
