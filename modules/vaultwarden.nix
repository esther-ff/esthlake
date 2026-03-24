{ config, lib, ... }:
let
  backupDir = "/var/backup/vw";
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  inherit (lib.modules) mkIf;

  cfg = config.estera.programs.vaultwarden;
in
{
  options.estera.programs.vaultwarden = {
    enable = mkEnableOption "vaultwarden";

    environmentFile = mkOption {
      description = "file containing the environment for the vaultwarden instance, should have the admin token";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services = {
      vaultwarden = {
        enable = true;

        inherit backupDir;
        environmentFile = cfg.environmentFile;

        config = {
          ROCKET_PORT = 8768;
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_LOG = "warn";
          SIGNUPS_ALLOWED = false;
        };
      };

      caddy = {
        enable = true;
        globalConfig = ''
          skip_install_trust
          auto_https disable_redirects
        '';
        virtualHosts."https://localhost:8000, https://192.168.0.2:8000".extraConfig = ''
          reverse_proxy localhost:${toString config.services.vaultwarden.config.ROCKET_PORT} {
            header_up X-Real-IP {remote_host}
          }

          tls internal
        '';
      };

    };
  };

}
