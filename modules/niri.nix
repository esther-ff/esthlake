{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.estera.programs.niri;
  cfgXwayland = config.estera.programs.xwayland.useSatellite;

  inherit (config.estera.flake.system) user;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types attrNames;
  inherit (config.home-manager.users.${user}.lib) niri;

  pathToWallpaper = "${cfg.wallpaperSource}/${cfg.wallpaper}";

in {
  options.estera.programs.niri = {
    enable = mkEnableOption "niri";

    wallpaperSource = mkOption {
      description = "directory containing wallpapers";
      type = types.path;
      default = ../assets/wallpapers;
    };

    wallpaper = mkOption {
      description =
        "file name of the wallpaper image located in assets/wallpapers/";
      type = types.enum (attrNames (builtins.readDir cfg.wallpaperSource));
      default = null;
    };
  };

  imports = [ inputs.niri.nixosModules.niri ];

  config = lib.modules.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    programs.niri = {
      enable = true;
      package = pkgs.niri-stable;
    };

    home-manager.users.${user} = {
      programs.niri = with niri.actions; {
        package = pkgs.niri-stable;
        # enable = true;
        settings = {
          window-rules = [{
            matches = [{ title = "Dunst"; }];
            open-floating = true;
          }];
          prefer-no-csd = true;

          spawn-at-startup = [
            { command = [ "firefox" ]; }
            { command = [ "swaybg" "-i" pathToWallpaper ]; }
            { command = [ "waybar" ]; }
          ] ++ lib.optional cfgXwayland {
            command = [ "xwayland-satellite" "&" ];
          };

          layout = {
            focus-ring = {
              active.color = "rgb(181 134 232)";
              width = 5;
            };
            shadow.enable = true;
          };
          binds = {
            "Alt+Q".action = spawn "alacritty";
            "Alt+D".action = spawn "rofi" "-show" "drun";
            "Alt+F".action = spawn "firefox";
            "Alt+C".action = close-window;
            "Alt+S".action = screenshot;

            "Alt+Shift+W".action = move-window-up;
            "Alt+Shift+S".action = move-window-down;

            "Alt+W".action = move-column-left;
            "Alt+A".action = move-column-right;

            "Alt+E".action = focus-column-left;
            "Alt+R".action = focus-column-right;

            "Alt+Left".action = set-column-width "+10%";
            "Alt+Right".action = set-column-width "-10%";

            "Alt+J".action = move-column-to-workspace-up;
            "Alt+K".action = move-column-to-workspace-down;

            # workspace keybinds
          } // builtins.listToAttrs (builtins.map (x: {
            name = "Alt+${toString x}";
            value = { action = focus-workspace x; };
          }) (builtins.genList (x: x + 1) 9))

          # column keybinds
          # // builtins.listToAttrs (builtins.map (x: {
          #   name = "Alt+Shift+${toString x}";
          #   value = { action = move-column-to-workspace x; };
          # }) (builtins.genList (x: x + 1) 9));
          ;
        };
      };
    };
  };
}
