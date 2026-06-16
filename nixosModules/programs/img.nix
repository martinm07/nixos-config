{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    naps2 # Scanning software
    darktable
    gimp # GNU Image Manipulation Program
    inputs.wayscriber.packages.${pkgs.system}.default # I imagine pkgs.system is the "x86_64-linux" string, like in nixpkgsUnstable declarations.
    inputs.wayscriber.packages.${pkgs.system}.wayscriber-configurator
  ];
}
