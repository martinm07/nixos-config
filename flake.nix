{
  description = "A very basic flake";

  inputs = {
    nixpkgsUnstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgsUnstable,
    ...
  }: let
    hostname = "dm01";
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit nixpkgsUnstable;};
      modules = [
        {
          system.configurationRevision = self.rev or self.dirtyRev or null;
        }
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./${hostname}.nix
      ];
    };
  };
}
