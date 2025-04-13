{config, pkgs, ...}:

{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
    }
  };

  xdg.configFile."sway/config".source = "/home/esther/.config/sway/config";
}
