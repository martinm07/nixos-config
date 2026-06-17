{
  config,
  pkgs,
  nixpkgsUnstable,
  lib,
  ...
}:
with lib; let
  cfg = config.myc.audio;

  patchedCarla = pkgs.carla.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.patchelf];
    postFixup =
      (old.postFixup or "")
      + ''
        patchelf --add-rpath ${pkgs.lib.makeLibraryPath [pkgs.gtk2]} \
          $out/lib/carla/carla-bridge-lv2-gtk2
      '';
  });
in {
  options.myc.audio = {
    enableLiveAudioMixing = lib.mkEnableOption "Enables low latency audio mixing and installs certain packages (qpwgraph, carla, calf)";
  };

  config = mkMerge [
    {
      environment.systemPackages = with pkgs; [
        spotify
        fatsort # Main use-case is sorting MP3 files on USB flash drives for CD players
        nixpkgsUnstable.legacyPackages.x86_64-linux.tauon # Music player
        puddletag # For adding metadata ("tags") to MP3/audio files (like title, album, cover art, etc.), supporting automatic patterns from the filenames
        musescore # Music notation
        transcribe # Music transcription
      ];
    }

    (mkIf cfg.enableLiveAudioMixing {
      environment.systemPackages = with pkgs; [
        qpwgraph # Audio mixer
        # carla # Effects manager
        calf # Audio effect plugins (like 'wah')
        patchedCarla
      ];
    })
  ];
}
