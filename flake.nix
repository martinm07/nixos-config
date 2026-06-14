{
  description = "System flake";

  inputs = {
    nixpkgsUnstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

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
    dolphin-overlay,
    ...
  } @ inputs: let
  in {
    nixosConfigurations.dm01 = nixpkgs.lib.nixosSystem {
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

        ./hosts/dm01/configuration.nix
      ];
    };

    nixosConfigurations.m02 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit nixpkgsUnstable;
        inherit inputs;
      };
      modules = [
        {
          system.configurationRevision = self.rev or self.dirtyRev or null;
          # nixpkgs.overlays = [
          #   dolphin-overlay.overlays.default
          # ];
        }

        ./hosts/m02/configuration.nix
      ];
    };
  };
}
