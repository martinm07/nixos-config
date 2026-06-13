{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    naps2 # Scanning software
    darktable
    gimp # GNU Image Manipulation Program
  ];
}
