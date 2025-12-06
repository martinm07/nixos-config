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
      exec hyprland
    '';
  };

  home.file.".config/hypr".source = ./hypr;
  home.file.".config/waybar".source = ./waybar;
  home.file.".config/foot".source = ./foot;
}
