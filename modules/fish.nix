{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.estera.programs.fish;
  inherit (config.estera.flake.system) user;
  inherit (lib.options) mkEnableOption;
in
{
  options.estera.programs.fish = {
    enable = mkEnableOption "fish";
  };

  config = lib.modules.mkIf cfg.enable {
    programs.fish.enable = true;
    home-manager.users.${user} = {
      programs.fish = {
        enable = true;
        interactiveShellInit = builtins.concatStringsSep "\n" [
          ''
            function fish_greeting
              uname -nrv
              echo
              echo "awrff wrff woof bark bark wrff arf arf"
              date
            end

            set -g fish_greeting
            set -x PATH "$HOME/.npm_packages/bin/" $PATH
            set -x DISPLAY ":0.0"
          ''
          (builtins.readFile ../assets/prompt.fish)
        ];

        shellAliases = {
          ctest = "cargo test";
          cmtest = "cargo miri test";
          cchck = "cargo check";
          v = "hx";
          ":q" = "exit";
          gcmt = "git commit -m";
          gpsh = "git push";
          nxsh = "nix-shell -p";
          cargo = "cargo mommy";
          nxr = "sudo nixos-rebuild switch --flake .#tgirl";
          snooze = "poweroff";
          nxd = "nix develop -c ${pkgs.fish}/bin/fish";
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
    };
  };
}
