{ config, pkgs, inputs, lib, ... }:

{
  imports = [ inputs.niri.homeModules.niri ];
  options.app.niri.enable = lib.mkEnableOption "niri";

  config =
    lib.mkIf (config.app.niri.enable) { programs.niri = { enable = true; }; };
}
