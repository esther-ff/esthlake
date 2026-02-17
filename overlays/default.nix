{ inputs, pkgs, ... }:
let
  overlayInput = { inherit inputs pkgs; };
in
{
  nixpkgs.overlays = [
    inputs.niri-nix.overlays.niri-nix
  ]
  ++ map (path: import path overlayInput) [
    ./ironbar.nix
    ./helix.nix
    ./zen-browser.nix
  ];
}
