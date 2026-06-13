{
  config,
  pkgs,
  nixpkgsUnstable,
  inputs,
  ...
}: {
  # Enable the X11 windowing system (but also Wayland? See https://github.com/NixOS/nixpkgs/issues/94799)
  services.xserver.enable = true;

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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Allows applications to interact with the Desktop Environment
  #  (e.g. screen sharing, file sharing, file opening, etc.)
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # DBus service for allowing applications to query and manipulate storage devices (like Dolphin)
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    ### ESSENTIAL DESKTOP FEATURES
    nixpkgsUnstable.legacyPackages.x86_64-linux.ironbar # Status bar
    wpaperd # Wallpaper manager
    swaynotificationcenter # SwayNC (notification manager that should also work with Hyprland)
    libnotify # Package that dunst depends on (TODO: Does SwayNC depend on it?)
    rofi # App launcher
    hyprsunset # Blue filter
    hyprpolkitagent
    wl-clipboard

    ### ESSENTIAL CLI TOOLS
    wget
    eza # A Rust alternative to ls/tree. Output uses colours (based on a theme) to include extra information.
    #     For info on the default theme:   https://github.com/eza-community/eza/blob/main/docs/theme.yml
    unzip

    ### ESSENTIAL DESKTOP APPS
    kdePackages.dolphin # File browser
    kdePackages.kfind # File search utility used by Dolphin
    mate.pluma # Text editor
    qalculate-gtk # Calculator (that is very cool)
    vlc # Video viewer/playback
    swayimg # Image viewer
    mate.atril # Document viewing & printing
    grim # Screenshot tool- makes screenshot from given area
    slurp # Allows to visually select area of screen (for grim)
    nixpkgsUnstable.legacyPackages.x86_64-linux.wayscriber # Screen annotation tool

    ### SETTINGS APPS
    pwvucontrol # Small audio controller/manager application
    nwg-displays # Small display manager application
    btop # System resources TUI
    networkmanagerapplet # Network manager
    nwg-look # GTK theme manager
    baobab # Disk usage analyser
    gparted # Installing gparted as a "system app" rather than a "user app" may be important. Must research the difference
    exfatprogs # Ability to operate on exFAT filesystems using gparted

    ### THEME
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    paper-gtk-theme
    orchis-theme
    kdePackages.breeze-icons
    papirus-icon-theme
  ];

  environment.sessionVariables = {
    # Hint for electron apps to use wayland compositor
    NIXOS_OZONE_WL = "1";
    # Make Anki use Wayland (instead of XWayland, which has performance issus, freezing, not working with fictx5, sometimes completely freezes)
    ANKI_WAYLAND = "1";
  };
}
