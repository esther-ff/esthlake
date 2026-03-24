{
  description = "Acero";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    ironbar.url = "path:./pkgs/ironbar";
    bigeon.url = "github:esther-ff/uuhbot";
    niri-nix.url = "git+https://codeberg.org/BANanaD3V/niri-nix";
    helix.url = "github:helix-editor/helix";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    nix-cachyos.url = "github:xddxdd/nix-cachyos-kernel/release";
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
