{
  description = "Acero";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";
  };

  outputs = inputs@{ nixpkgs, home-manager, niri, ... }:
    let
      lib = import ./lib/default.nix nixpkgs.lib;
      # system = "x86_64-linux";
      # systems = [ "x86_64-linux" ]; # all i got :)
      nixosConfigurations = import ./hosts { inherit lib inputs; };
      # forAllSystems = lib.genAttrs systems;

    in { inherit nixosConfigurations; };

}
