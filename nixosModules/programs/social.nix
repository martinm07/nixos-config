{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    discord
    element-desktop # Matrix client
    zoom-us
  ];
}
