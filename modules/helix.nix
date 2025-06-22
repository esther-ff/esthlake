{ config, lib, pkgs, ... }:
let
  cfg = config.estera.programs.helix;

  inherit (config.estera.flake.system) user;
  inherit (lib.estera) colorPicker flattenToml colorScheme;
  inherit (colorScheme) fg bg;
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;

  themeSet = {
    ui = {
      background = { bg = "background"; };
      cursor = {
        main = {
          fg = "red";
          modifiers = [ "reversed" ];
        };

        primary = {
          fg = "blue";
          modifiers = [ "reversed" ];
        };

        match = {
          fg = "yellow";
          underline.style = {
            color = "background";
            style = "dashed";
          };
        };
      };

      text = {
        main = {
          fg = "fg";
          bg = "bg";
        };
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
        main = { bg = "backgroundLight"; };

        primary = {
          fg = "blue";
          modifiers = [ "reversed" ];
        };
      };

      window = { fg = "red"; };

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
        main = { fg = "text"; };
        selected = { fg = "text"; };
      };

      virtual = {
        ruler = { bg = "text"; };
        whitespace = { fg = "text"; };

        inlay-hint = { fg = "red"; };
        jump-label = {
          fg = "red";
          modifiers = [ "bold" ];
        };
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
    }; # String literal.

    property = { main.fg = "text"; }; # Regex group names.
    special = {
      main.fg = "cyan";
    }; # Special symbols e.g `?` in Rust, `...` in Hare.
    attribute = {
      main.fg = "magenta";
    }; # Class attributes, html tag attributes.

    type = {
      main.fg = "blue";
    }; # Variable type, like integer or string, including program defined classes, structs etc..
    type.builtin = {
      fg = "blue";
    }; # Primitive types of the language (string, int, float).
    type.enum.variant = { fg = "blue"; }; # A variant of an enum.

    constructor = {
      main.fg = "blue";
    }; # Constructor method for a class or struct.

    constant = { main.fg = "green"; }; # Constant value
    constant.builtin = {
      fg = "green";
    }; # Special constants like `true`, `false`, `none`, etc.
    constant.builtin.boolean = { fg = "cyan"; }; # True or False.
    constant.character = { fg = "yellow"; }; # Constant of character type.
    constant.character.escape = { fg = "yellow"; }; # escape codes like \n.
    constant.numeric = { fg = "cyan"; }; # constant integer or float value.
    constant.numeric.integer = { fg = "cyan"; }; # constant integer value.
    constant.numeric.float = { fg = "cyan"; }; # constant float value.

    string = { main.fg = "yellow"; };
    regexp = { fg = "yellow"; }; # Regular expression literal.

    special = { fg = "yellow"; }; # Strings containing a path, URL, etc.
    special.path = { fg = "yellow"; }; # String containing a file path.
    special.url = { fg = "yellow"; }; # String containing a web URL.
    special.symbol = { fg = "yellow"; };

    comment = {
      main.fg = "darkFg";
      modifiers = [ "bold" ];
    };
    comment.line = {
      fg = "darkFg";
      modifiers = [ "bold" ];
    };
    comment.block = {
      fg = "darkFg";
      modifiers = [ "bold" ];
    };
    comment.block.documentation = {
      fg = "darkFg";
      modifiers = [ "bold" "italic" ];
    };

    variable = { fg = "text"; };
    variable.builtin = {
      fg = "cyan";
      modifiers = [ "bold" ];
    };
    variable.parameter = { fg = "magenta"; };
    variable.other.member = { fg = "text"; };

    label = { fg = "cyan"; };

    punctuation = { main.fg = "text"; };
    punctuation.delimiter = { fg = "blue"; };

    punctuation.bracket = {
      bg = "bg";
      fg = "blue";
    }; # Parentheses, angle brackets, etc.

    keyword = {
      main.fg = "green";
      control = { fg = "green"; }; # Control keywords.
      control.conditional = { fg = "green"; }; # `if`, `else`, `elif`.
      control.repeat = { fg = "green"; }; # `for`, `while`, `loop`.
      control.import = { fg = "green"; }; # `import`, `export` `use`.
      control.return = { fg = "green"; }; # `return` in most languages.
      control.exception = {
        fg = "green";
      }; # `try`, `catch`, `raise`/`throw` and related.

      operator = { fg = "green"; }; # `or`, `and`, `in`.
      directive = { fg = "green"; }; # Preprocessor directives (#if in C...).
      function = {
        fg = "green";
        modifier = [ "bold" ];
      }; # The keyword to define a function: def, fun, fn.
    }; # Language reserved keywords.

    operator = {
      main.fg = "green";
    }; # Logical, mathematical, and other operators.

    function = {
      main.fg = "cyan";
      builtin = { fg = "cyan"; };
      method = { fg = "cyan"; }; # Class / Struct methods.
      macro = { fg = "cyan"; };
      special = { fg = "cyan"; }; # Preprocessor in C.
    };

    tag = {
      main.fg = "blue";
      error = { fg = "red"; };
    };

    diagnostic.info.underline = {
      color = "blue";
      style = "cur";
    };
    diagnostic.hint.underline = {
      color = "green";
      style = "cur";
    };
    diagnostic.warning.underline = {
      color = "yellow";
      style = "cur";
    };
    diagnostic.error.underline = {
      color = "red";
      style = "cur";
    };
    diagnostic.unnecessary = { modifiers = [ "dim" ]; };
    diagnostic.deprecate = { modifiers = [ "crossed_out" ]; };

    info = {
      fg = "blue";
      modifiers = [ "bold" "italic" ];
    };

    hint = {
      fg = "green";
      modifiers = [ "bold" "italic" ];
    };

    warning = {
      fg = "yellow";
      modifiers = [ "bold" "italic" ];
    };

    error = {
      fg = "red";
      modifiers = [ "bold" "italic" ];
    };

    namespace = { fg = "blue"; };

    diff = {
      plus = { fg = "green"; };
      minus = { fg = "red"; };
      delta = { fg = "yellow"; };
      delta.moved = { fg = "blue"; };
    };
  };

  theme = {
    inherit fg;
    inherit bg;
    background = bg;
    backgroundLight = colorScheme.lightBg;
    text = fg;
    textDark = colorScheme.darkFg;

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
  } // (flattenToml themeSet);
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
