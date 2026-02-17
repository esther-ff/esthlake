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
      mkMerge
      ;
    inherit (lib.strings) toJSON;

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
              "privacy.purge_trackers.date_in_cookie_database" = 0;
              "privacy.purge_trackers.last_purge" = 1771281400663;
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
            };

          extraPolicies = {
            OfferToSaveLogins = true;
            DisableTelemetry = true;
            ExtensionSettings =
              let
                mkUrl = shortId: "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                mkExtension =
                  { shortId, guid }:
                  {
                    ${guid} = {
                      install_url = mkUrl shortId;
                      installation_mode = "normal_installed";
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
                ];
              in
              mkMerge (map mkExtension exts);

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
                  URLTemplate = "https://wiki.archlinux.org/w/index.php?search={searchTerms}";
                  IconURL = "https://wiki.archlinux.org/favicon.ico";
                  Alias = "@aw";
                }
                {
                  Name = "noogle";
                  URLTemplate = "https://noogle.dev/q?term={searchTerms}";
                  IconURL = "https://noogle.dev/favicon.ico";
                  Alias = "@ng";
                }
              ];
            };
          };

        };

    # zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
  }
)
