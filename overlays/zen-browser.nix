{
  inputs,
  pkgs,
  lib,
  ...
}:
(
  final: prev:
  let
    inherit (lib)
      concatLines
      mapAttrsToList
      mergeAttrsList
      ;

    inherit (lib.strings) toJSON;
    downloadDir = "/data/Pobrane";
  in
  {
    zen-browser =
      pkgs.wrapFirefox
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
        {
          extraPrefs =
            let
              convertPrefs =
                prefs:
                concatLines (mapAttrsToList (name: value: "lockPref(${toJSON name}, ${toJSON value});") prefs);
            in
            convertPrefs {
              "privacy.annotate_channels.strict_list.enabled" = true;
              "privacy.bounceTrackingProtection.hasMigratedUserActivationData" = true;
              "privacy.bounceTrackingProtection.mode" = 1;
              "privacy.clearHistory.browsingHistoryAndDownloads" = false;
              "privacy.clearHistory.cache" = false;
              "privacy.clearHistory.cookiesAndStorage" = false;
              "privacy.clearHistory.formdata" = true;
              "privacy.clearOnShutdown_v2.formdata" = true;
              "privacy.clearSiteData.cookiesAndStorage" = false;
              "privacy.fingerprintingProtection" = true;
              "privacy.history.custom" = true;
              "privacy.query_stripping.enabled" = true;
              "privacy.query_stripping.enabled.pbmode" = true;
              "privacy.resistFingerprinting" = true;
              "privacy.resistFingerprinting.exemptedDomains" = "*.example.invalid,*.googleapis.com";
              "privacy.resistFingerprinting.pbmode" = true;
              "privacy.resistFingerprinting.randomization.canvas.disable_for_chrome" = true;
              "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
              "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
              "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
              "privacy.trackingprotection.allow_list.baseline.enabled" = false;
              "privacy.trackingprotection.allow_list.convenience.enabled" = false;
              "privacy.trackingprotection.allow_list.hasMigratedCategoryPrefs" = true;
              "privacy.trackingprotection.allow_list.hasUserInteractedWithETPSettings" = true;
              "privacy.trackingprotection.consentmanager.skip.pbmode.enabled" = false;
              "privacy.trackingprotection.emailtracking.enabled" = true;
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "security.block_fileuri_script_with_wrong_mime" = true;
              "browser.translations.automaticallyPopup" = true;
            };

          extraPolicies = {
            OfferToSaveLogins = true;
            DisableTelemetry = true;

            # Get the FUCK OUT!!!
            GenerativeAI = {
              Enabled = false;
              Chatbot = false;
              LinkPreviews = false;
              TabGroups = false;
              Locked = true;
            };

            HardwareAcceleration = true;
            DefaultDownloadDirectory = downloadDir;

            ExtensionSettings =
              let
                mkUrl = shortId: "https://addons.mozilla.org/firefox/downloads/latest/${shortId}/latest.xpi";
                mkExtension =
                  { shortId, guid }:
                  {
                    ${guid} = {
                      install_url = mkUrl guid;
                      installation_mode = "force_installed";
                    };
                  };
                exts = [
                  {
                    shortId = "ublock-origin";
                    guid = "uBlock0@raymondhill.net";
                  }
                  {
                    shortId = "darkreader";
                    guid = "addon@darkreader.org";
                  }
                  {
                    shortId = "everforest_theme";
                    guid = "{39ec6c53-67ca-42cc-9f23-339cca400ef2}";
                  }
                ];
              in
              mergeAttrsList (map mkExtension exts);

            ManagedBookmarks =
              let
                bookmark = name: url: {
                  inherit name url;
                };
              in
              [
                (bookmark "RISC-V spec (Privileged)" "https://five-embeddev.com/riscv-priv-isa-manual/Priv-v1.12/supervisor.html")
                (bookmark "RISC-V assembly" "https://projectf.io/posts/riscv-cheat-sheet/")
                (bookmark "Proton mail" "https://mail.proton.me")
                (bookmark "Github" "https://github.com/esther-ff")
                (bookmark "Codeberg" "https://codeberg.com/esther-ff")
              ];

            SearchEngines = {
              Default = "ddg";
              Add = [
                {
                  Name = "nixpkgs packages";
                  URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
                  IconURL = "https://wiki.nixos.org/favicon.ico";
                  Alias = "@np";
                }
                {
                  Name = "nixos wiki";
                  URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
                  IconURL = "https://wiki.nixos.org/favicon.ico";
                  Alias = "@nw";
                }
                {
                  Name = "archwiki";
                  URLTemplate = "https://wiki.archlinux.org/index.php?search={searchTerms}";
                  IconURL = "https://wiki.archlinux.org/favicon.ico";
                  Alias = "@aw";
                }
                {
                  Name = "noogle";
                  URLTemplate = "https://noogle.dev/q?term={searchTerms}";
                  IconURL = "https://noogle.dev/favicon.ico";
                  Alias = "@ng";
                }
                {
                  Name = "docs.rs";
                  URLTemplate = "https://docs.rs/releases/search?query={searchTerms}";
                  IconURL = "https://docs.rs/favicon.ico";
                  Alias = "@rd";
                }
                {
                  Name = "ruststd";
                  URLTemplate = "https://doc.rust-lang.org/std/?search={searchTerms}";
                  IconURL = "https://rust-lang.org/favicon.ico";
                  Alias = "@rs";
                }
              ];
            };
          };
        };
  }
)
