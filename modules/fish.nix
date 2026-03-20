{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.estera.programs.fish;
  inherit (lib.options) mkEnableOption;
in
{
  options.estera.programs.fish = {
    enable = mkEnableOption "fish";
  };

  config = lib.modules.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = builtins.concatStringsSep "\n" [
        ''
          set -g fish_greeting ""
        ''
        (builtins.readFile ../assets/prompt.fish)
      ];

      shellAliases = {
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
    };

    environment.systemPackages = with pkgs; [
      fishPlugins.fzf-fish
      fishPlugins.hydro
      fishPlugins.grc
      grc
    ];
  };
}
