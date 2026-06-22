{
  config,
  pkgs,
  nixpkgsUnstable,
  lib,
  ...
}:
with lib; let
  cfg = config.myc.jellyfin;
in {
  options.myc.jellyfin = {
    enable = lib.mkEnableOption "Enables Jellyfin server";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.jellyfin = {
        enable = true;
        openFirewall = true;
        user = "martinm";
      };

      environment.systemPackages = with pkgs; [
        jellyfin-web
        jellyfin-ffmpeg
      ];
    })
  ];
}
