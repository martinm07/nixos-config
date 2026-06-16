{
  config,
  pkgs,
  nixpkgsUnstable,
  ...
}: {
  environment.systemPackages = with pkgs; [
    spotify
    fatsort # Main use-case is sorting MP3 files on USB flash drives for CD players
    nixpkgsUnstable.legacyPackages.x86_64-linux.tauon # Music player
    puddletag # For adding metadata ("tags") to MP3/audio files (like title, album, cover art, etc.), supporting automatic patterns from the filenames
    musescore # Music notation
    transcribe # Music transcription
    carla # Audio mixer
  ];
}
