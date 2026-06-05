{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mapAttrsToList;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  ip = "192.168.0.7";
  cfg = config.estera.programs.searxng;
  port = 8888;
  caddyPort = 8080;
in
{
  options.estera.programs.searxng.enable = mkEnableOption "searxng";

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      caddyPort
    ];

    networking.firewall.allowedUDPPorts = [
      caddyPort
    ];

    services = {
      caddy = {
        enable = true;
        globalConfig = ''
          skip_install_trust
          auto_https disable_redirects
        '';
        virtualHosts."https://localhost:${toString caddyPort}, https://${ip}:${toString caddyPort}".extraConfig =
          ''
            reverse_proxy localhost:${toString port} {
              header_up X-Real-IP {remote_host}
            }

            tls internal
          '';
      };
      searx = {
        enable = true;
        redisCreateLocally = true;

        settings = {
          general = {
            debug = false;
            instance_name = "Abadan";
            donation_url = false;
            contact_url = false;
            privacypolicy_url = false;
            enable_metrics = false;
          };

          ui = {
            hotkeys = "vim";
            default_theme = "simple";
            default_locale = "en";
          };

          server = {
            inherit port;
            bind_address = "127.0.0.1";
            secret_key = config.sops.secrets.searxng_secret_key.path;
            image_proxy = true;
          };

          outgoing = {
            enable_http2 = true;
          };

          engines =
            let
              f = name: value: { inherit name; } // value;
            in
            mapAttrsToList f {
              "startpage".disabled = true;
              "duckduckgo".disabled = true;
              "brave".disabled = true;
              "bing".disabled = true;
              "mojeek".disabled = true;
              "mwmbl".disabled = true;
              "mwmbl".weight = 0.4;
              "qwant".disabled = true;
              "crowdview".disabled = true;
              "crowdview".weight = 0.5;
              "curlie".disabled = true;
              "ddg definitions".disabled = false;
              "ddg definitions".weight = 2;
              "wikibooks".disabled = true;
              "wikidata".disabled = true;
              "wikiquote".disabled = true;
              "wikisource".disabled = true;
              "wikispecies".disabled = true;
              "wikispecies".weight = 0.5;
              "wikiversity".disabled = true;
              "wikiversity".weight = 0.5;
              "wikivoyage".disabled = true;
              "wikivoyage".weight = 0.5;
              "currency".disabled = true;
              "dictzone".disabled = true;
              "lingva".disabled = true;
              "bing images".disabled = true;
              "brave.images".disabled = true;
              "duckduckgo images".disabled = true;
              "google images".disabled = false;
              "qwant images".disabled = true;
              "1x".disabled = true;
              "artic".disabled = false;
              "deviantart".disabled = true;
              "flickr".disabled = true;
              "imgur".disabled = true;
              "library of congress".disabled = true;
              "material icons".disabled = true;
              "material icons".weight = 0.2;
              "openverse".disabled = true;
              "pinterest".disabled = true;
              "svgrepo".disabled = false;
              "unsplash".disabled = false;
              "wallhaven".disabled = true;
              "wikicommons.images".disabled = false;
              "yacy images".disabled = true;
              "bing videos".disabled = true;
              "brave.videos".disabled = true;
              "duckduckgo videos".disabled = true;
              "google videos".disabled = true;
              "qwant videos".disabled = true;
              "dailymotion".disabled = true;
              "google play movies".disabled = true;
              "invidious".disabled = true;
              "odysee".disabled = true;
              "peertube".disabled = false;
              "piped".disabled = true;
              "rumble".disabled = true;
              "sepiasearch".disabled = true;
              "vimeo".disabled = true;
              "youtube".disabled = false;
              "brave.news".disabled = true;
              "google news".disabled = true;
            };
        };
      };
    };
  };
}
