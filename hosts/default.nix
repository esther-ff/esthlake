{ inputs, lib, ... }:
let
  inherit (inputs) self;
  inherit (lib) nixosSystem map listToAttrs;
  sysConfigDir = dir:
    import (lib.path.append dir "system.nix") { inherit inputs; };

  mkSystem = extra: directory:
    nixosSystem {
      system = null;
      modules = [ ./common/core ../modules directory ] ++ extra;
      specialArgs = { inherit inputs lib self; };
    };

  allHosts = hosts:
    listToAttrs (map (host: {
      name = (sysConfigDir host.directory).estera.flake.system.host;
      value = mkSystem [ ] host.directory;
    }) hosts);

in allHosts [{ directory = ./tgirl; }]
