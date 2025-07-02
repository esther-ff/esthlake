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

    # i dedicate this line to poz
    # the idealist that suggested this
    # because machines may aswell be somewhat human
    # we treat them as opaque gods of computation
    # but we never realize their costs on our population
    # stop for a while, and realise the blood cost
    # of your electronic devices, of the whole world
    # can you truly change it?
    # Yes, you can. However you need many
    # fiery souls with one idea
    # to destroy the current world
    # and build one great new world
    # a union of all the peoples
    # in the world
    # like a nix function, pure from
    # inequality and oppression.
    #
    # au revoir, dear reader.
    gender = mkOption {
      description = "hehe... is this machine transgender???? (maybe???)";
      type = types.any; # be free, my module. for free anarchy....!
      default =
        null; # Who cares for society's constructs, if society doesn't care for you?
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
