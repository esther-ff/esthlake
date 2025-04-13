{ pkgs, config, lib, programs, ... }:

let musicLib = import ./music-manager.nix;
in {
  home = {
    username = "esther";
    homeDirectory = "/home/esther";
    stateVersion = "24.11";

    packages = with pkgs; [
      hyprland
      fish
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      jdk
      protonvpn-cli_2
      protonvpn-gui
      firefox
      clang-tools
      uwsm
    ];

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT = "1";
      XDG_SESSION_TYPE = "wayland";
    };

    file.".npmrc".text = lib.generators.toINIWithGlobalSection { } {
      globalSection = { prefix = "$HOME/.npm-packages"; };
    };
  } // musicLib.handleFileList [{
    name = "cat.jpg";
    link =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Cat_November_2010-1a.jpg/800px-Cat_November_2010-1a.jpg";
    hash = "0r3jwna7jxw2wafpsgqvbk7ka7qkmp6dx6ndql70pbd20k688qsw";
  }];

  programs.home-manager.enable = true;

  # programs.uwsm.waylandCompositors = [
  #   {
  #     prettyName = "hyprland";
  #     comment = "hyprland on uwsm YAY";
  #     binPath = "${pkgs.hyprland}/bin/Hyprland";
  #   }
  #   {
  #     prettyName = "niri";
  #     comment = "swipe swipe scroll";
  #     binPath = "${pkgs.niri}/bin/niri";
  #   }
  # ];

  # XDG Portal
  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal ];
      config = { common.default = "*"; };
    };
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];
    settings = {
      "$mod" = "SUPER";
      "exec-once" = [ "waybar" "xdg-desktop-portal-hyprland" "alacritty" ];

      bind = [
        "$mod, F, exec, firefox"
        "$mod, Q, exec, alacritty"
        "$mod, R, exec, rofi -show drun"
        "$mod, S, exec, thunar"
        "$mod, C, killactive"
        "$mod, J, togglesplit"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
      ] ++ (builtins.concatLists (builtins.genList (i:
        let workspace = i + 1;
        in [
          "$mod, code:1${toString i}, workspace, ${toString workspace}"
          "$mod SHIFT, code:1${toString i}, movetoworkspace, ${
            toString workspace
          }"
        ]) 9));

      decoration = {
        rounding = 0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.2;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;

        border_size = 2;

        # Colors
        "col.inactive_border" = "rgb(282828) rgb(928374) 45deg";
        "col.active_border" = "rgb(fe8019) rgb(d65d0e) 45deg";

        resize_on_border = false;

        allow_tearing = false;

        layout = "dwindle";
      };

      animations = { enabled = "no"; };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = { new_status = "master"; };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = "pl";
        follow_mouse = 1;
        sensitivity = 0;
      };

      gestures = { workspace_swipe = false; };

      windowrulev2 = [
        "suppressevent maximize, class: .*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };
  };

  # Fish configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
        echo Defend the Trocadero! En avant!
        uname -a
        date
      end

      set -g fish_greeting

      set -x PATH "$HOME/.npm_packages/bin/" $PATH
    '';

    shellAbbrs = { projs = "cd /data/git"; };

    shellAliases = {
      ctest = "cargo test";
      cmtest = "cargo miri test";
      cchck = "cargo check";
      gcmt = "git commit -m";
      gpsh = "git push";
      nxsh = "nix-shell -p";
      proj = "hx /data/git/";
      # hmreload =
      #   "home-manager switch --flake ~/.config/nixpkgs/home-cfg#esther -b backup";
      nxrebuild = "sudo nixos-rebuild switch --flake /data/git/nixyay#enby";
      hmcfg = "hx /data/git/nixyay/home.nix";
      nixcfg = "hx /data/git/nixyay";
    };

    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }

      {
        name = "hydro";
        src = pkgs.fishPlugins.hydro.src;
      }

      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf.src;
      }

      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
          sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        };
      }
    ];
  };

  # Helix configuration
  programs.helix = {
    enable = true;
    settings = {
      theme = "onedark";
      editor = { completion-timeout = 5; };
    };

    languages = {

      language-server.clangd = {
        command = "${pkgs.clang-tools}/bin/clangd";
        # args = [ "--std=c++17" ];
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }

        {
          name = "cpp";
          auto-format = true;
          formatter.command = "${pkgs.clang-tools}/bin/clang-format";
        }
      ];
    };
  };

  programs.niri = with config.lib.niri.actions; {
    enable = true;
    settings = {
      window-rules = [{
        matches = [{ title = "Dunst"; }];
        open-floating = true;
      }];

      prefer-no-csd = true;
      spawn-at-startup =
        [ { command = [ "alacritty" ]; } { command = [ "waybar" ]; } ];
      layout = {
        focus-ring = {
          active.color = "rgb(224 107 117)";
          width = 2;
        };
        shadow.enable = true;
      };
      binds = {
        "Alt+Q".action = spawn "alacritty";
        "Alt+W".action = spawn "rofi" "-show" "drun";
        "Alt+F".action = spawn "firefox";
        "Alt+C".action = close-window;

        "Alt+Shift+W".action = move-window-up;
        "Alt+Shift+S".action = move-window-down;

        "Alt+Shift+Z".action = move-column-left;
        "Alt+Shift+X".action = move-column-right;

        "Alt+E".action = focus-column-left;
        "Alt+R".action = focus-column-right;

        # workspace keybinds
      } // builtins.listToAttrs (builtins.map (x: {
        name = "Alt+${toString x}";
        value = { action = focus-workspace x; };
      }) (builtins.genList (x: x + 1) 9))
      # keyminds for move-column-to-workspace
        // builtins.listToAttrs (builtins.map (x: {
          name = "Alt+Shift+${toString x}";
          value = { action = move-column-to-workspace x; };
        }) (builtins.genList (x: x + 1) 9));
    };
  };

  programs.waybar = {
    enable = true;
    settings = [{
      position = "top";
      mod = "dock";
      exclusive = true;
      passthrough = false;
      height = 0;
      gtk-layer-shell = true;

      modules-left = [ "niri/workspaces" ];

      modules-right = [ "cpu" "memory" "clock" "tray" ];

      "niri/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        warp-on-scroll = false;
        format = "{name} {icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          "6" = "";
          "active" = "<";
          "default" = "";
        };

        persistent-workspaces = { "*" = 6; };

      };

      tray = { spacing = 10; };

      clock = {
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
        format-alt = "{:%Y-%m-%d}";
      };

      cpu = {
        format = "cpu: {usage}%";
        tooltip = false;
      };

      memory = { format = "memory: {}%"; };

      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };

      network = {
        format-ethernet = "{ipaddr}/{cidr} ";
        tooltip-format = "{ifname} via {gwaddr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };

      pulseaudio = {
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
      };
    }];
  };
}

