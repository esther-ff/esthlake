{
  description = "Wahoo! NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";
  };

  outputs = { nixpkgs, home-manager, niri, ... }:
    let
      # lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ niri.overlays.niri ];
      };
    in {

      homeConfigurations = {
        esther = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix niri.homeModules.niri ];
        };
      };

      nixosConfigurations.tgirl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          { nixpkgs.overlays = [ niri.overlays.niri ]; }

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              users.esther = { pkgs, ... }: {
                imports = [ ./home.nix niri.homeModules.niri ];
              };
            };
          }
          # Separated for clarity
        ];
      };
    };
}

