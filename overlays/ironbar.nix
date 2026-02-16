{ inputs, pkgs, ... }:
(final: prev: {
  ironbar = inputs.ironbar.packages.${pkgs.stdenv.hostPlatform.system}.default;
})
