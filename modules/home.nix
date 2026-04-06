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
    mapAttrsToList
    mapAttrs
    filterAttrs
    ;

  inherit (builtins) isNull;
  inherit (pkgs) writeText;
  inherit (lib.options) mkEnableOption mkOption;

  fileSubmodule.options = {
    content = mkOption {
      description = "content of the file";
      type =
        with types;
        nullOr (oneOf [
          str
          package
          path
        ]);
      default = null;
    };

    link = mkOption {
      description = "symlink to a file";
      type = with types; nullOr str;
      default = null;
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
      type = with types; attrsOf (submodule homeSubmodule);
      default = { };
    };
  };

  config =
    let
      enabled = filterAttrs (_: user: user.enable) config.estera.village.home;

    in
    {
      systemd.user.tmpfiles.users = mapAttrs (
        _: user:
        let
          toRuleSimple = name: path: "L+ ${user.homeDirectory}/${name} - - - - ${path}";

          toRule =
            name: value:
            let
              path = if isString value then writeText name value else value;
            in
            toRuleSimple name path;

          fileOrLink =
            name: value:
            if !(isNull value.link) then
              toRuleSimple name value.link
            else if !(isNull value.content) then
              toRule name value.content
            else
              "";
        in
        {
          rules = mapAttrsToList fileOrLink user.files;
        }
      ) enabled;
    };
}
