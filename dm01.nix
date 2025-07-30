# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: let
  hostname = "dm01";
in {
  networking.hostName = hostname;
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  programs.nh = {
    enable = true;
    flake = "/home/martinm/.config/system";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
      "steam"
      "steam-unwrapped"
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [mozc];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      ubuntu_font_family
      fira-code
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = ["Noto Sans CJK"];
        serif = ["Noto Serif CJK"];
        monospace = ["Ubuntu Mono"];
      };
    };
  };

  # Enable the X11 windowing system (but also Wayland? See https://github.com/NixOS/nixpkgs/issues/94799)
  services.xserver.enable = true;

  # The "displayManager" refers to the lockscreen. Alternatives to lightdm are available.
  services.xserver.displayManager.lightdm.enable = true;
  # It seems like it is the desktop manager which decides for itself whether to use X11 or Wayland.
  # There is no Nix configuration like "servies.wayland.enable", and the existing "services.xserver.enable"
  #  does not necessarily mean that we will be using X11 (again, that is up to the desktop environmemt).
  # Budgie (currently on version 10.9) does NOT support Wayland.
  # Version 10.10 (currently in development) will ONLY support Wayland.
  #
  # `Sway` seems to be like another desktop manager, but one that DOES use Wayland, though described as a
  #  "window manager", which basically makes it a minimal desktop environment primarily navigated with keyboard shortcuts.
  # Sway can be enabled relatively easily in NixOS by using `programs.sway.enable`.
  # It seems possible to also do a "build-your-own-DE" instead of using something like Budgie, or KDE Plasma. You could have
  #  "Sway"/"Hyprland" to composite application windows, "waybar" to have a taskbar, "anyrun" for an application launcher,
  #  something else for notifications, something for widgets, etc. etc.
  # There is a repository of software that supports Wayland that can be used in constructin the desktop experience:
  #  https://github.com/rcalixte/awesome-wayland
  # There is also a useful tutorial (and blogger in general) for creating a Wayland NixOS desktop using Sway here:
  #  https://www.drakerossman.com/blog/wayland-on-nixos-confusion-conquest-triumph#getting-more-stuff-for-sway
  # For the question of why some categories software need/want a "Wayland-specific" implementation, refer to this Claude conversation:
  #  https://claude.ai/share/326a6e03-8145-44d5-b79b-21bcafbce0e9
  services.xserver.desktopManager.budgie.enable = true;

  environment.budgie.excludePackages = [
    pkgs.gnome-terminal
  ];
  services.xserver.excludePackages = [pkgs.xterm];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "extd";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.martinm = {
    isNormalUser = true;
    description = "Martin Molnar";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      thunderbird
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "martinm";

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # --- --- --- -- --- --- ---
    # --- COMMAND LINE TOOLS ---
    # --- --- --- -- --- --- ---
    wget
    gtop
    eza # A Rust alternative to ls/tree. Output uses colours (based on a theme) to include extra information.
    #     For info on the default theme:   https://github.com/eza-community/eza/blob/main/docs/theme.yml
    xorg.xmodmap

    # --- --- --- --- --- ---
    # --- DEVELOPER TOOLS ---
    # --- --- --- --- --- ---
    kitty
    # There's also `zed-editor-fhs` for wrapping the editor in a Filesystem Hierarchy Standard (FHS) sandbox, allegedly
    #  for allowing extensions to work without Nix-specific configuration. These are extensions that try to run
    #  dynamically linked libraries (DLLs) e.g. that are language servers (like rust-analyzer): https://github.com/NixOS/nixpkgs/issues/309662
    # Refer to this for the use-cases of an FHS wrapper: https://nixos.org/manual/nixpkgs/stable/#sec-fhs-environments
    # However, this does create inconvenciences, like the Zed terminal running isolated from the regular system, missing everything not
    #  in the user directory like /etc, /nix/store, etc. and missing certain privelages. As well as some funky stuff potentially freezing the system
    #  (TODO: waiting to see if that happens again after switching off of zed-editor-fhs)
    #  and not getting PATH updates after system version switches (just speculation, though).
    # I'm pretty sure the problem with DLLs can also be fixed by using programs.nix-ld. Try to use that before switching back to zed-editor-fhs.
    #
    # From what I read there also seems to be another issue with `zed-editor` (not -fhs) where during installing it tries to install some default pre-built LSPs
    #  into ~/.local/share/zed/languages/ (especially a JSON LSP for editing Zed's settings.json) and fails to do that because of Nix.
    # Since I started with zed-editor-fhs I got these files in my home directory, and after that the regular `zed-editor` was fine (i.e. I got lucky :))
    # See:   https://github.com/NixOS/nixpkgs/issues/421750     and:   https://wiki.nixos.org/wiki/Zed#LSP_Support
    zed-editor
    nixd # Nix LSP
    alejandra # Nix formatter
    (python313.withPackages (
      ps:
        with ps; [
          flask
          flask_wtf
          wtforms
          twilio
          regex
        ]
    ))

    # --- --- --- --
    # --- GAMING ---
    # --- --- --- --

    steam-run
    mangohud # Provides a small HUD on games for monitoring FPS, system resources, etc.
    protonup # Provides a CLI command `protonup` which installs the latest version of Proton GE
    lutris
    heroic

    # --- --- --- --- ---
    # --- CASUAL APPS ---
    # --- --- --- --- ---
    discord
    element-desktop
    spotify
  ];

  programs.steam = {
    enable = true;
    # Runs games in an "optimized micro compositor" which MAY help for games that have problems upscaling/my specific resolution
    #  REMEMBER compositors from the X11/Wayland research? They tell applications what part of the screen to render and "composes" them all
    #  together into one video output with windows into all the different applications currently running (Hyprland is a compositor, so is Sway).
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = ["amdgpu"];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.git.enable = true;
  programs.git.config = {
    user.name = "martinm07";
    user.email = "martin.github07@gmail.com";
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [
    # Includes packages that imperative DLLs (for example, downloaded by Zed extensions) are asking to have exist
    #  in the library path.
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
