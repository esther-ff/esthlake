{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.estera.programs.niri;
  cfgXwayland = config.estera.programs.xwayland.useSatellite;

  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types attrNames;
  inherit (inputs.niri-nix.lib) validatedConfigFor mkNiriKDL;
  inherit (inputs.niri-nix.packages.${pkgs.stdenv.hostPlatform.system}) niri-unstable;

  pathToWallpaper = "${cfg.wallpaperSource}/${cfg.wallpaper}";

  niriConfig = {
    input.keyboard = {
      xkb = {
        layout = "pl";
      };
    };

    window-rule = [
      {
        match = {
          _props.title._raw = "\"Dunst\"";
        };
        open-floating = true;
      }
    ];

    prefer-no-csd = true;

    spawn-at-startup = [
      [
        "swaybg"
        "-i"
        "${pathToWallpaper}"
      ]
      [ "ironbar" ]
    ]
    ++ lib.optional cfgXwayland [ "xwayland-satellite" ];

    layout = {
      focus-ring = {
        active-color = "rgb(219, 188, 127)";
        width = 2;
      };
    };

    animations = {
      off = [ ];
    };

    binds =
      let
        spawn = list: { spawn = list; };
        close-window = {
          close-window = [ ];
        };
        move-column-left = {
          move-column-left = [ ];
        };
        move-column-right = {
          move-column-right = [ ];
        };
        move-column-to-workspace-up = {
          move-column-to-workspace-up = [ ];
        };
        move-column-to-workspace-down = {
          move-column-to-workspace-down = [ ];
        };
        focus-column-left = {
          focus-column-left = [ ];
        };
        focus-column-right = {
          focus-column-right = [ ];
        };
        move-window-up = {
          move-window-up = [ ];
        };
        move-window-down = {
          move-window-down = [ ];
        };

        set-column-width = val: { set-column-width = val; };
        focus-workspace = val: { focus-workspace = val; };
      in
      {
        "Alt+Q" = spawn "alacritty";
        "Alt+D" = spawn [
          "rofi"
          "-show"
          "drun"
        ];
        "Alt+F" = spawn "zen";
        "Alt+C" = close-window;
        "Alt+S" = {
          screenshot = [ ];
        };

        "Alt+Shift+W" = move-window-up;
        "Alt+Shift+S" = move-window-down;

        "Alt+W" = move-column-left;
        "Alt+A" = move-column-right;

        "Alt+E" = focus-column-left;
        "Alt+R" = focus-column-right;

        "Alt+Left" = set-column-width "+5%";
        "Alt+Right" = set-column-width "-5%";

        "Alt+J" = move-column-to-workspace-up;
        "Alt+K" = move-column-to-workspace-down;

        # workspace keybinds
      }
      // builtins.listToAttrs (
        builtins.map (x: {
          name = "Alt+${toString x}";
          value = focus-workspace x;

        }) (builtins.genList (x: x + 1) 9)
      );
  };

in
{
  options.estera.programs.niri = {
    enable = mkEnableOption "niri";

    wallpaperSource = mkOption {
      description = "directory containing wallpapers";
      type = types.path;
      default = ../assets/wallpapers;
    };

    wallpaper = mkOption {
      description = "file name of the wallpaper image located in assets/wallpapers/";
      type = types.enum (attrNames (builtins.readDir cfg.wallpaperSource));
      default = null;
    };
  };

  config = lib.modules.mkIf cfg.enable (
    let
      builtNiriConfig = pkgs.writeText "niri-config.kdl" (
        validatedConfigFor niri-unstable (mkNiriKDL niriConfig)
      );
    in
    {
      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };

      environment.variables = {
        NIRI_CONFIG = "${builtNiriConfig}";
      };
    }
  );
}
