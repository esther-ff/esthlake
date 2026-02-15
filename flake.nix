{
  description = "Acero";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ironbar.url = "path:./pkgs/ironbar";
    bigeon.url = "github:esther-ff/uuhbot";
    niri-nix.url = "git+https://codeberg.org/BANanaD3V/niri-nix";

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      chaotic,
      ironbar,
      bigeon,
      sops-nix,
      niri-nix,
      ...
    }:
    let
      lib = import ./lib/default.nix nixpkgs.lib;
      # system = "x86_64-linux";
      # systems = [ "x86_64-linux" ]; # all i got :)
      nixosConfigurations = import ./hosts {
        inherit
          lib
          inputs
          chaotic
          bigeon
          sops-nix
          niri-nix
          ;
      };
      # forAllSystems = lib.genAttrs systems;

    in
    {
      inherit nixosConfigurations;
    };

}
