{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  overlayInput = { inherit inputs pkgs lib; };
in
{
  nixpkgs.overlays = [
    inputs.niri-nix.overlays.niri-nix
    inputs.nix-cachyos.overlays.pinned
  ]
  ++ map (path: import path overlayInput) [
    ./ironbar.nix
    ./helix.nix
    ./zen-browser.nix
  ];
}
