{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [
    inputs.niri-nix.overlays.niri-nix
    (import ./ironbar.nix { inherit inputs pkgs; })
  ];
}
