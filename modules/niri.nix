{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.estera.programs.niri;
  cfgFoot = config.estera.programs.foot.enable;

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
      [ "xwayland-satellite" ]
    ]
    ++ lib.optional cfgFoot [
      "foot"
      "--server"
    ];

    layout = {
      focus-ring = {
        active-color = "rgb(219, 188, 127)";
        width = 2;
      };
      gaps = 12;
    };

    animations = {
      off = [ ];
    };

    gestures.hot-corners = {
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
        "Alt+Q" = spawn "footclient";
        "Alt+D" = spawn "fuzzel";
        "Alt+L" = spawn "swaylock";
        "Alt+F" = spawn "zen";
        "Alt+C" = close-window;
        "Alt+S".screenshot = [ ];
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

    screenshotPath = mkOption {
      description = "path where niri should save screenshots";
      type = types.str;
    };

    autostart = mkOption {
      description = "if niri should set up an autostart rule with bash";
      default = false;
      type = types.bool;
    };
  };

  config = lib.modules.mkIf cfg.enable (
    let
      builtNiriConfig = pkgs.writeText "niri-config.kdl" (
        validatedConfigFor niri-unstable (mkNiriKDL niriConfig)
      );
    in
    {
      assertions = [
        {
          assertion = config.estera.programs.foot.enable;
          message = "the niri configuration requires foot!";
        }
        {
          assertion = config.estera.programs.fuzzel.enable;
          message = "the niri configuration requires fuzzel!";
        }
      ];

      nixpkgs.overlays = [ inputs.niri-nix.overlays.niri-nix ];

      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };

      environment.etc.profile = lib.modules.mkIf cfg.autostart {
        text = ''
          if [ "$XDG_VTNR" -eq 1 ] && [ -z "$WAYLAND_DISPLAY" ] && [[ $(tty) = "/dev/tty1" ]]; then
              SHELL=${pkgs.bash} niri-session -l
              exit
          fi
        '';
      };

      programs.bash = lib.modules.mkIf cfg.autostart {
        enable = true;
      };

      environment.variables = {
        NIRI_CONFIG = "${builtNiriConfig}";
      };

      programs.xwayland = {
        enable = true;
      };

      environment.systemPackages = [ pkgs.xwayland-satellite ];
    }
  );
}
