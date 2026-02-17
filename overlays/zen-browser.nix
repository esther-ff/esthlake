{ inputs, pkgs, ... }:
(final: prev: {
  zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
})
