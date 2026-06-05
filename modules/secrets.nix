{ config, lib, ... }:
let
  inherit (lib.options) mkEnableOption;
  user = config.estera.flake.system.user;

  defaultSopsFile = ../secrets.yaml;
  keyFilePath = "/home/${user}/.config/sops/age/keys.txt";
in
{
  options.estera.secrets.enable = mkEnableOption "secrets";

  config = {
    sops = {
      age.keyFile = keyFilePath;
      inherit defaultSopsFile;
      secrets = {
        mullvad_private_key = { };
        bigeon_discord_token = { };
        admin_token_env = { };
        user_password = { };
        ssh_private_key = {
          owner = user;
        };
        searxng_secret_key = { };
      };
    };

    estera.village.home.${user}.files.".ssh/id_ed25519".link = "/run/secrets/ssh_private_key";
  };
}
