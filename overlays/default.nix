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
    inputs.nix-cachyos.overlays.pinned
  ]
  ++ map (path: import path overlayInput) [
    ./ironbar.nix
    ./helix.nix
    ./zen-browser.nix
  ];
}
