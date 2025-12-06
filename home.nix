{
  config,
  pkgs,
  ...
}: {
  home.username = "martinm";
  home.homeDirectory = "/home/martinm";
  home.stateVersion = "25.05";
  programs.git.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
    };
    # profileExtra = ''
    #   if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    #     exec uwsm start -S hyprland-uwsm.desktop
    #   fi
    # '';
    profileExtra = ''
      exec hyprland --config ~/.config/system/config/hypr/hyprland.conf
    '';
  };

  home.file.".config/hypr".source = ./config/hypr;
  home.file.".config/waybar".source = ./config/waybar;
}
