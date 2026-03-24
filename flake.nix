{
  description = "Aaaaaa...";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel/release";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ironbar = {
      url = "path:./pkgs/ironbar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bigeon = {
      url = "github:esther-ff/uuhbot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      ironbar,
      bigeon,
      sops-nix,
      niri-nix,
      helix,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      nixosConfigurations = import ./hosts {
        lib = import ./lib/default.nix nixpkgs.lib;
        inherit
          inputs
          bigeon
          sops-nix
          niri-nix
          helix
          ;
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixfmt
              nil
            ];
          };
        }
      );
    };

}
