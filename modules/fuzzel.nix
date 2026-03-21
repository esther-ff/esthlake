{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) generators isString;
  inherit (lib.options) mkEnableOption;
  inherit (lib.generators) toINI;
  inherit (pkgs) writeShellScriptBin writeText;
  inherit (lib.modules) mkIf;
  cfg = config.estera.programs.fuzzel;
in
{
  options.estera.programs.fuzzel.enable = mkEnableOption "fuzzel";

  config =

    let
      iniConfig =
        toINI
          {
            mkKeyValue = generators.mkKeyValueDefault {
              mkValueString = v: if isString v then ''"${v}"'' else generators.mkValueStringDefault { } v;
            } "=";
          }
          {

            main = {
              font = "MonaspiceNe NF:size=13";
              use-bold = true;
              message = "da sind wir aber immer noch!";
              prompt = "><::> ";
              terminal = "${pkgs.foot}/bin/footclient";
            };

            border = {
              radius = 0;
              width = 5;
            };

            colors =
              with lib.estera.colorScheme;
              let
                inherit (lib) splitString elemAt;
                toRgba =
                  color:
                  let
                    cleaned = elemAt (splitString "#" color) 1;
                  in
                  cleaned + "ff";
              in
              {
                background = toRgba bg;
                text = toRgba fg;
                prompt = toRgba red;
                message = toRgba red;
                placeholder = toRgba gray;
                input = toRgba white;
                match = toRgba yellow;
                selection = toRgba green;
                selection-text = toRgba bg;
                border = toRgba yellow;
              };
          };

    in
    mkIf cfg.enable {
      environment.systemPackages = [
        (writeShellScriptBin "fuzzel" ''
          ${pkgs.fuzzel}/bin/fuzzel --config ${writeText "fuzzel.ini" iniConfig}
        '')
      ];
    };
}
