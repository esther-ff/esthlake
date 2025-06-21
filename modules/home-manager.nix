{ config, lib, inputs, ... }:
let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (config.estera.flake.system) user;

  cfg = config.estera.home-manager;
  stateVersion = mkDefault "25.05";
in {

  options.estera.home-manager = { enable = mkEnableOption "home-manager"; };

  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = mkIf cfg.enable {
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${user} = {
        programs = {

          home-manager.enable = true;
        };

        home = {
          username = user;
          homeDirectory = "/home/${user}";
          inherit stateVersion;
        };
      };

    };
  };
}
