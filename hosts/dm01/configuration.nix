{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../nixosModules
    ./hardware-configuration.nix
  ];

  myc.hostname = "dm01";

  myc.boot.enableGRUB = true;
  myc.boot.enableSDDM = true;
  myc.boot.addHyprlandCustomDM = true;

  ####################################

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
      "steam"
      "steam-unwrapped"
      "obsidian"
      "google-chrome"
      "zoom-us"
      "zoom"
      "osu-lazer-bin"
      "transcribe"
    ];

  # Set your time zone.
  time.timeZone = "Europe/Dublin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_IE.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.martinm = {
    isNormalUser = true;
    description = "Martin Molnar";
    # "lp" is a group for "scanner printers" (i.e. all-in-one printers) I believe
    extraGroups = ["networkmanager" "wheel" "input" "docker" "scanner" "lp" "video" "render"];
    packages = with pkgs; [
      thunderbird
    ];
    shell = pkgs.zsh;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 48 * 1024; # 48 GB
    }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
