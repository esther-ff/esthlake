{ inputs, pkgs, ... }:
final: prev: {
  helix = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;
}
