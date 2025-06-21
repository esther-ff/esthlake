{
  description = "Girlskissing!!!!!! :3";

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
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      systems = [ "x86_64-linux" ]; # all i got :)

      nixosConfigurations = import ./hosts { inherit lib inputs; };
      forAllSystems = lib.genAttrs systems;

      #   nixosConfigurations.tgirl = nixpkgs.lib.nixosSystem {
      #     system = "x86_64-linux";
      #     modules = [
      #       ./configuration.nix
      #       { nixpkgs.overlays = [ niri.overlays.niri ]; }

      #       home-manager.nixosModules.home-manager
      #       {
      #         home-manager = {
      #           useGlobalPkgs = true;
      #           useUserPackages = true;
      #           backupFileExtension = "bak";
      #           users.esther = { pkgs, ... }: {
      #             imports = [ ./home.nix niri.homeModules.niri ];
      #           };
      #         };
      #       }
      #       # Separated for clarity
      #     ];
      #   };
      # };
      #

    in { inherit nixosConfigurations; };

}
