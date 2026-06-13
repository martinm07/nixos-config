{lib, ...}: {
  imports = [
    ./ai.nix
    ./boot.nix
    ./development.nix
    ./devices.nix
    ./essentials.nix
    ./fonts.nix
    ./gaming.nix
    ./hyprland.nix
    ./keyboard.nix
    ./nix.nix
    ./printing.nix

    ./programs/audio.nix
    ./programs/browser.nix
    ./programs/img.nix
    ./programs/other.nix
    ./programs/social.nix
    ./programs/text.nix
  ];
}
