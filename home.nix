{ pkgs, config, lib, ... }:

let
  musicLib = import ./music-manager.nix;
  username = "esther";
in {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
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
      zerotierone
      linuxKernel.packages.linux_6_6.perf
      swaybg
      rofi-wayland
    ];

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT = "1";
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "hx";
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
          background = "0x140e07";
          foreground = "0xf09ac7";
        };

        normal = {
          black = "0x660e60";
          blue = "0xf09ac7";
          cyan = "0xe195cf";
          green = "0xc095e4";
          magenta = "0xc48bdf";
          red = "0xb586e8";
          white = "0xbc5090";
          yellow = "0x893f71";
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

  # Fish configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
        uname -nrv
        echo
        echo "awrff wrff woof bark bark wrff arf arf"
        date
      end

      set -g fish_greeting

      set -x PATH "$HOME/.npm_packages/bin/" $PATH
    '';

    shellAbbrs = { projs = "cd /data/git"; };

    shellAliases = {
      ctest = "cargo mommy test";
      cmtest = "cargo mommy miri test";
      cchck = "cargo mommy check";
      gcmt = "git commit -m";
      gpsh = "git push";
      nxsh = "nix-shell -p";
      proj = "hx /data/git/";
      cargo = "cargo mommy";
      nxrebuild = "sudo nixos-rebuild switch --flake /data/git/nixyay#tgirl";
      hmcfg = "hx /data/git/nixyay/home.nix";
      nixcfg = "hx /data/git/nixyay";
      snooze = "poweroff";

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

      theme = "veuves";
      editor = {
        completion-timeout = 5;
        line-number = "relative";
        file-picker.hidden = false;
        end-of-line-diagnostics = "hint";
      };

      # editor.inline-diagnostics = { cursor-line = "warning"; };

      keys = {
        insert = {
          up = "no_op";
          down = "no_op";
          left = "no_op";
          right = "no_op";
          pageup = "no_op";
          pagedown = "no_op";
          home = "no_op";
          end = "no_op";
        };
      };
    };

    themes = {
      veuves = {

        palette = {
          dark = "#140e07";
          light = "#f09ac7";

          default = "#140e07";
          black = "#660e60";
          blue = "#f09ac7";
          cyan = "#e195cf";
          green = "#c095e4";
          magenta = "#c48bdf";
          red = "#c48bdf";
          white = "#c48bdf";
          yellow = "#839f71";
          gray = "#d290d7";

          # light-red = red;
          # light-green = green;
          # light-yellow = yellow;
          # light-blue = blue;
          # light-magenta = magenta;
          # light-cyan = cyan;
          # light-gray = gray;
        };

        "ui.background" = { bg = "dark"; };
        "ui.text" = { fg = "light"; };
        "ui.text.info" = {
          bg = "element_background";
          fg = "text";
        };

        "ui.selection" = {
          bg = "light";
          fg = "dark";
        };

        "ui.selection.primary" = {
          bg = "light";
          fg = "dark";
        };

        "ui.cursor" = {
          fg = "dark";
          bg = "light";
        };

        "ui.cursor.primary" = {
          fg = "dark";
          bg = "red";
        };

        "ui.cursor.insert" = {
          fg = "dark";
          bg = "light";
        };

        "ui.cursor.select" = {
          fg = "dark";
          bg = "light";
        };

        "ui.cursor.match" = {
          fg = "dark";
          bg = "light";
        };

      } // (let
        config = ''
          'ui.window' = { fg = "border" } # Window border between splits.
          'ui.gutter' = { bg = "background" } # Left gutter for diagnostics and breakpoints.
          'ui.text.focus' = { fg = "text", bg = "element_background" } # Selection highlight in buffer-picker or file-picker.

          'ui.linenr' = { fg = "text_muted" } # Line numbers.
          'ui.linenr.selected' = { fg = "text" } # Current line number.

          'ui.virtual' = { fg = "text_muted" } 
          'ui.virtual.ruler' = { bg = "element_hover" } 
          'ui.virtual.whitespace' = { fg = "text_muted" } 

          'ui.statusline' = { fg = "text", bg = "background" } # Status line.
          'ui.statusline.active' = { fg = "text", bg = "background" } # Status line in focused windows.
          'ui.statusline.inactive' = { fg = "text_muted", bg = "background" } # Status line in unfocused windows.
          "ui.statusline.normal" = { fg = "text", bg = "background" } # Statusline mode during normal mode (only if editor.color-modes is enabled)
          "ui.statusline.insert" = { fg = "green", bg = "background" } # Statusline mode during insert mode (only if editor.color-modes is enabled)
          "ui.statusline.select" = { fg = "yellow", bg = "background" } # Statusline mode during select mode (only if editor.color-modes is enabled)

          'ui.help' = { fg = "text", bg = "background_elevated" } # `:command` descriptions above the command line.

          'ui.highlight' = { bg = "element_background" } # selected contents of symbol pickers (spc-s, spc-S) and current line in buffer picker (spc-b).

          'ui.menu' = { fg = "text", bg = "background_elevated" } # Autocomplete menu.
          'ui.menu.selected' = { fg = "text", bg = "element_background" } # Selected autocomplete item.

          'ui.popup' = { bg = "background_elevated" } # Documentation popups (space-k).
          'ui.popup.info' = { fg = "text", bg = "background_elevated" } # Info popups box (space mode menu).


          # all the keys here are Treesitter scopes.

          'property' = { fg = "text" } # Regex group names.
          'special' = { fg = "cyan" } # Special symbols e.g `?` in Rust, `...` in Hare.
          'attribute' = { fg = "magenta" } # Class attributes, html tag attributes.

          'type' = { fg = "blue" } # Variable type, like integer or string, including program defined classes, structs etc..
          'type.builtin' = { fg = "blue" } # Primitive types of the language (string, int, float).
          'type.enum.variant' = { fg = "blue" } # A variant of an enum.

          'constructor' = { fg = "blue" } # Constructor method for a class or struct.

          'constant' = { fg = "green" } # Constant value
          'constant.builtin' = { fg = "green" } # Special constants like `true`, `false`, `none`, etc.
          'constant.builtin.boolean' = { fg = "cyan" } # True or False.
          'constant.character' = { fg = "yellow" } # Constant of character type.
          'constant.character.escape' = { fg = "yellow" } # escape codes like \n.
          'constant.numeric'  = { fg = "cyan" } # constant integer or float value.
          'constant.numeric.integer' = { fg = "cyan" } # constant integer value.
          'constant.numeric.float' = { fg = "cyan" } # constant float value.

          'string' = { fg = "yellow" } # String literal.
          'string.regexp' = { fg = "yellow" } # Regular expression literal.
          'string.special' = { fg = "yellow" } # Strings containing a path, URL, etc.
          'string.special.path' = { fg = "yellow" } # String containing a file path.
          'string.special.url' = { fg = "yellow" } # String containing a web URL.
          'string.special.symbol' = { fg = "yellow" } # Erlang/Elixir atoms, Ruby symbols, Clojure keywords.

          'comment' = { fg = "comm" } # This is a comm.
          'comment.line' = { fg = "comm" } # Line comms, like this.
          'comment.block' = { fg = "comm" } # Block comms, like /* this */ in some languages.
          'comment.block.documentation' = { fg = "comm" } # Doc comms, e.g '///' in rust.

          'variable' = { fg = "text" } # Variable names.
          'variable.builtin' = { fg = "cyan" } # Language reserved variables: `this`, `self`, `super`, etc.
          'variable.parameter' = { fg = "magenta" } # Function parameters.
          'variable.other.member' = { fg = "text" } # Fields of composite data types (e.g. structs, unions).

          'label' = { fg = "cyan" } # Loop labels, among other things.

          'punctuation' = { fg = "text_muted" } # Any punctuation symbol.
          'punctuation.delimiter' = { fg = "blue" } # Commas, colons or other delimiter depending on the language.
          'punctuation.bracket' = { fg = "text_muted" } # Parentheses, angle brackets, etc.

          'keyword' = { fg = "green" } # Language reserved keywords.
          'keyword.control' = { fg = "green" } # Control keywords.
          'keyword.control.conditional' = { fg = "green" } # `if`, `else`, `elif`.
          'keyword.control.repeat' = { fg = "green" } # `for`, `while`, `loop`.
          'keyword.control.import' = { fg = "green" } # `import`, `export` `use`.
          'keyword.control.return' = { fg = "green" } # `return` in most languages.
          'keyword.control.exception' = { fg = "green" } # `try`, `catch`, `raise`/`throw` and related.
          'keyword.operator' = { fg = "green" } # `or`, `and`, `in`.
          'keyword.directive' = { fg = "green" } # Preprocessor directives (#if in C...).
          'keyword.function' = { fg = "green" } # The keyword to define a function: 'def', 'fun', 'fn'.

          'operator' = { fg = "green" } # Logical, mathematical, and other operators.

          'function' = { fg = "cyan" }
          'function.builtin' = { fg = "cyan" }
          'function.method' = { fg = "cyan" } # Class / Struct methods.
          'function.macro' = { fg = "cyan" }
          'function.special' = { fg = "cyan" } # Preprocessor function in C.

          'tag' = { fg = "blue" } # As in <body> for html, css tags.
          'tag.error' = { fg = "red" } # Erroneous closing html tags.

          'namespace' = { fg = "blue" } # Namespace or module identifier.

          'diff.plus' = { fg = "green" } # Additions.
          'diff.minus' = { fg = "red" } # Deletions.
          'diff.delta' = { fg = "yellow" } # Modifications.
          'diff.delta.moved' = { fg = "blue" } # Renamed or moved files.
        '';
      in builtins.fromTOML config);

    };

    languages = {

      language-server.clangd = {
        command = "${pkgs.clang-tools}/bin/clangd";
        # args = [ "--std=c++17" ];
      };

      language-server.rust-analyzer.config = { check.command = "clippy"; };

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
    package = pkgs.niri-stable;
    enable = true;
    settings = {
      window-rules = [{
        matches = [{ title = "Dunst"; }];
        open-floating = true;
      }];

      prefer-no-csd = true;
      spawn-at-startup = [
        { command = [ "firefox" ]; }
        { command = [ "swaybg" "-i" "/data/wallpapers/evening-sky.png" ]; }
        { command = [ "waybar" ]; }
      ];
      layout = {
        focus-ring = {
          active.color = "rgb(181 134 232)";
          width = 5;
        };
        shadow.enable = true;
      };
      binds = {
        "Alt+Q".action = spawn "alacritty";
        "Alt+W".action = spawn "rofi" "-show" "drun";
        "Alt+F".action = spawn "firefox";
        "Alt+C".action = close-window;
        "Alt+S".action = screenshot;

        "Alt+Shift+W".action = move-window-up;
        "Alt+Shift+S".action = move-window-down;

        "Alt+Shift+Z".action = move-column-left;
        "Alt+Shift+X".action = move-column-right;

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

  programs.waybar = {
    enable = true;
    style = ''
             * {
              font-family: "Fira Code";
              font-size: 12px;
            }

            #cpu, #memory, #clock
            {
              color: #140e07;
              background-color: #e195cf;
              padding: 0 3px;
              margin-bottom: 4px;
              /* border: 1px solid #140e07; */
            }

            #waybar {
              background-color: #140e07;
              color: #f09ac7;
            }

            window#waybar {
              padding: 5px;
              border-bottom: 2px solid #f09ac7;
            }

            #tray {
              background-color: #b586e8;
              color: #140e07;
            }

            #workspaces {
              background-color: #e195cf;
              color: #140e07;
                      margin-bottom: 4px;

              /* border: 2px solid #140e07; */
            }

            #workspaces button.active { background-color:  #f09ac7; }
            #workspaces button.focused {
                  background-color: #b586e8;
                  /* box-shadow: inset 0 -3px #b586e8; */
             }
            #workspaces button.urgent { background-color:  #c095e4; }

      button {
        padding: 0px;
        background-color: transparent;
        box-shadow: inset 0 -3px transparent;
        border: none;
        border-radius: 0;
      }

    '';

    settings = [{
      position = "top";
      mod = "dock";
      exclusive = true;
      passthrough = false;
      height = 20;
      spacing = 2;
      gtk-layer-shell = true;

      modules-left = [ "niri/workspaces" ];
      modules-right = [ "cpu" "memory" "clock" ];

      "niri/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        warp-on-scroll = false;
        format = "{icon}";
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "6";
          # "active" = "";
          # "default" = "";
        };
        persistent-workspaces = { "*" = 6; };
      };

      # tray = { spacing = 10; };

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

      memory = { format = "mem: {}%"; };

      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };

      # network = {
      #   format-ethernet = "{ipaddr}/{cidr} ";
      #   tooltip-format = "{ifname} via {gwaddr} ";
      #   format-linked = "{ifname} (No IP) ";
      #   format-disconnected = "Disconnected ⚠";
      #   format-alt = "{ifname}: {ipaddr}/{cidr}";
      # };

      # pulseaudio = {
      #   format = "{volume}% {icon} {format_source}";
      #   format-bluetooth = "{volume}% {icon} {format_source}";
      #   format-bluetooth-muted = " {icon} {format_source}";
      #   format-muted = " {format_source}";
      #   format-source = "{volume}% ";
      #   format-source-muted = "";
      #   format-icons = {
      #     headphone = "";
      #     hands-free = "";
      #     headset = "";
      #     phone = "";
      #     portable = "";
      #     car = "";
      #     default = [ "" "" "" ];
      #   };
      #   on-click = "pavucontrol";
      # };
    }];
  };

  programs.rofi = {
    enable = true;
    font = "FiraCode 14";
    location = "center";
    package = pkgs.rofi-wayland;
    # modes = [ "drun" ];

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
      background = "#140e07";
      foreground = "#f09ac7";
    in {
      "*" = {
        background-color = mkLiteral background;
        foreground-color = mkLiteral foreground;
        border-color = mkLiteral "rgba( 181, 134, 232, 100 %)";
      };
    };

    terminal = "alacritty";

  };
}

