{ config, pkgs, lib, ... }:
let
  cfg = config.estera.programs.xwayland;
  inherit (lib) types;
  inherit (lib.options) mkOption mkEnableOption;
in {
  options.estera.programs.xwayland = {
    enable = mkEnableOption "xwayland";

    useSatellite = mkOption {
      type = types.bool;
      default = false;
      description = "whether to use xwayland-satellite";
    };
  };

  config = lib.modules.mkIf cfg.enable {
    programs.xwayland = { enable = true; };

    environment.systemPackages = [ ]
      ++ lib.optional cfg.useSatellite pkgs.xwayland-satellite;
  };
}
