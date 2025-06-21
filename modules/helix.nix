{ config, lib, pkgs, ... }:
let
  scheme = import ../assets/theme.nix;
  inherit (import ../lib) colorPicker flattenToml;
  inherit (lib) mkIf;
  inherit (scheme) fg bg;
  inherit (lib.options) mkEnableOption;
  inherit (config.estera.flake.system) user;

  cfg = config.estera.programs.helix;
  themeSet = {
    ui = {
      background = { bg = "bg"; };
      cursor = {
        main = {
          fg = "dark";
          bg = "light";
        };

        primary = {
          fg = "dark";
          bg = "light";
        };

        insert = {
          fg = "dark";
          bg = "light";
        };

        select = {
          fg = "dark";
          bg = "light";
        };

        match = {
          fg = "dark";
          bg = "light";
        };
      };

      text = {
        main = { fg = "light"; };

        info = {
          bg = "bg";
          fg = "fg";
        };

        focus = {
          fg = "text";
          bg = "bg";
        };
      };

      selection = {
        main = {
          bg = "light";
          fg = "dark";
        };

        primary = {
          bg = "light";
          fg = "dark";
        };
      };

      window = { fg = "border"; };

      gutter = { bg = "bg"; };

      statusline = {
        main = {
          fg = "text";
          bg = "bg";
        };
        active = {
          fg = "text";
          bg = "bg";
        };
        inactive = {
          fg = "text";
          bg = "bg";
        };
        normal = {
          fg = "text";
          bg = "bg";
        };
        insert = {
          fg = "green";
          bg = "bg";
        };
        select = {
          fg = "yellow";
          bg = "bg";
        };
      };

      linenr = {
        main = { fg = "text_muted"; };
        selected = { fg = "text"; };
      };

      virtual = {
        ruler = { bg = "element_hover"; };
        whitespace = { fg = "text_muted"; };
      };

      help = {
        fg = "text";
        bg = "bg";
      };

      highlight = { bg = "bg"; };

      menu = {
        main = {
          fg = "text";
          bg = "yellow";
        };

        selected = {
          fg = "text";
          bg = "blue";
        };
      };

      popup = {
        main = {
          bg = "yellow";
          fg = "fg";
        };

        info = {
          bg = "bg";
          fg = "fg";
        };
      };
    };
  };
  theme =  {
    inherit fg;
    inherit bg;

    background = bg;
    text = fg;

    dark = bg;
    light = fg;

    default = colorPicker 0;
    black = colorPicker 1;
    blue = colorPicker 2;
    cyan = colorPicker 3;
    green = colorPicker 4;
    magenta = colorPicker 5;
    red = colorPicker 6;
    white = colorPicker 7;
    yellow = colorPicker 8;
    gray = colorPicker 9;

    light-black = colorPicker 10;

    light-blue = colorPicker 11;
    light-cyan = colorPicker 12;
    light-green = colorPicker 13;
    light-magenta = colorPicker 14;
    light-red = colorPicker 15;
  } // (flattenToml lib themeSet);
in {
  options.estera.programs.helix = { enable = mkEnableOption "helix"; };

  config = mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.helix = {
        enable = true;
        themes = { montrouge = theme; };
        settings = {
          theme = "montrouge";
          editor = {
            completion-timeout = 5;
            line-number = "relative";
            file-picker.hidden = false;
            end-of-line-diagnostics = "hint";
          };

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
    };
  };
}
