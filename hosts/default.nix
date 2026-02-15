{
  inputs,
  lib,
  # chaotic,
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
    extra: directory:
    nixosSystem {
      system = null;
      modules = [
        ./common/core
        ../modules
        directory
        # chaotic.nixosModules.default
        bigeon.nixosModules.bigeon
        sops-nix.nixosModules.sops
        niri-nix.nixosModules.default
        # chaotic.nixosModules.nyx-cache
        # chaotic.nixosModules.nyx-overlay
        # chaotic.nixosModules.nyx-registry
      ]
      ++ extra;
      specialArgs = { inherit inputs lib self; };
    };

  allHosts =
    hosts:
    listToAttrs (
      map (host: {
        name = (sysConfigDir host.directory).estera.flake.system.host;
        value = mkSystem [ ] host.directory;
      }) hosts
    );

in
allHosts [ { directory = ./tgirl; } ]
