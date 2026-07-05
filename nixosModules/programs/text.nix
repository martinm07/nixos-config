{
  config,
  pkgs,
  ...
}: let
  linkedApp = import ../../apps/linked-derivation.nix {inherit pkgs;};
  dailyyouApp = import ../../apps/dailyyou-derivation.nix {inherit pkgs;};
in {
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    linkedApp # Trialing this to replace TickTick's habit log
    dailyyouApp
    obsidian
    calibre
  ];
}
