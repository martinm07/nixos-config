{
  description = "A very basic flake";

  inputs = {
    nixpkgsUnstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgsUnstable,
    home-manager,
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
        }
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./${hostname}.nix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.martinm = import ./home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
