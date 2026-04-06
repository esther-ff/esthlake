{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.options) mkEnableOption;
in
{
  options.estera.sound.enable = mkEnableOption "sound";

  config = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    environment.systemPackages = with pkgs; [
      pavucontrol
      pipewire
    ];
  };
}
