{
  config,
  lib,
  ...
}:
let
  cfg = config.estera.programs.zoxide;
in
{
  options.estera.programs.zoxide = {
    enable = lib.options.mkEnableOption "zoxide";
  };

  config = lib.modules.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = false;
    };
  };
}
