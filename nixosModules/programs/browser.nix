{
  config,
  pkgs,
  ...
}: {
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    google-chrome # Mainly for NativShark, which is almost unusable on Firefox thanks to audio tracks sporatically not loading
  ];
}
