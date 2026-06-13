{
  description = "System flake";

  inputs = {
    nixpkgsUnstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Fixes the "Open with" menu not being populated/ Dolphin forgetting file associations with applications
    dolphin-overlay.url = "github:rumboon/dolphin-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgsUnstable,
    home-manager,
    dolphin-overlay,
    ...
  } @ inputs: let
    hostname = "dm01";
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit nixpkgsUnstable;
        inherit inputs;
      };
      modules = [
        {
          system.configurationRevision = self.rev or self.dirtyRev or null;
          nixpkgs.overlays = [
            dolphin-overlay.overlays.default
          ];
        }
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        # ./${hostname}.nix
        ./hosts/${hostname}/configuration.nix

        # home-manager.nixosModules.home-manager
        # {
        #   home-manager = {
        #     useGlobalPkgs = true;
        #     useUserPackages = true;
        #     users.martinm = import ./home.nix;
        #     backupFileExtension = "backup";
        #   };
        # }
      ];
    };
  };
}
