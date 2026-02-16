{
  inputs,
  lib,
  bigeon,
  sops-nix,
  niri-nix,
  ...
}:
let
  inherit (inputs) self;
  inherit (lib) nixosSystem map listToAttrs;
  sysConfigDir = dir: import (lib.path.append dir "system.nix") { inherit inputs; };

  mkSystem =
    directory:
    nixosSystem {
      modules = [
        ./common
        ../modules
        directory
        bigeon.nixosModules.bigeon
        sops-nix.nixosModules.sops
        niri-nix.nixosModules.default
        (import ../overlays)
      ];
      specialArgs = { inherit inputs lib self; };
    };

  allHosts =
    hosts:
    listToAttrs (
      map (host: {
        name = (sysConfigDir host).estera.flake.system.host;
        value = mkSystem host;
      }) hosts
    );

in
allHosts [ ./tgirl ]
