{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    types
    isString
    ;
  inherit (lib.options) mkEnableOption mkOption;

  fileSubmodule.options = {
    content = mkOption {
      description = "content of the file";
      type =
        with types;
        oneOf [
          str
          package
          path
        ];
      default = "";
    };
  };

  homeSubmodule.options = {
    name = mkOption {
      type = types.str;
      description = "username";
    };

    homeDirectory = mkOption {
      type = types.str;
      description = "home directory";
    };

    files = mkOption {
      type = types.attrsOf (types.submodule fileSubmodule);
      description = "files in the home directory";
      default = { };
    };

    enable = mkEnableOption "home";
  };
in
{
  options.estera.village = {
    home = mkOption {
      description = "user-specific settings";
      type = types.attrsOf (types.submodule homeSubmodule);
      default = { };
    };
  };

  config =
    let
      enabled = lib.filterAttrs (_: user: user.enable) config.estera.village.home;
      toRule =
        home: name: value:
        let
          path = if isString value then pkgs.writeText name value else value;
        in
        "L+ ${home}/${name} - - - - ${path}";

    in
    {
      systemd.user.tmpfiles.users = lib.mapAttrs (_: user: {
        rules = lib.mapAttrsToList (name: value: toRule user.homeDirectory name value.content) user.files;
      }) enabled;
    };
}
