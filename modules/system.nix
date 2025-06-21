# describes the environment

{ config, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;

  cfg = config.estera.flake.system;
in {
  options.estera.flake.system = {
    host = mkOption {
      description = "hostname for this pawsome device :3";
      type = types.str;
      default = "tgirl";
    };

    user = mkOption {
      description = "the master of this pawwsome device :3";
      type = types.str;
      default = "esther";
    };

    target = mkOption {
      description =
        "the target (example: x86_64-linux) of this glorious machine!!!!";
      type = types.enum [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      default = "x86_64-linux";
    };

    pronouns = mkOption {
      description = "pronouns of this machine, treat them humanely too :3";
      type = types.listOf types.str;
      default = [ "she" "they" ];
    };
  };

  config = {
    networking.hostName = cfg.host;
    users.users.${cfg.user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "audio" ];
    };
  };
}
