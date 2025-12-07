# {
#   config,
#   pkgs,
#   lib,
#   ...
# }: {
#   home.username = "martinm";
#   home.homeDirectory = "/home/martinm";
#   home.stateVersion = "25.11";
#   xdg.enable = true;
#   programs.home-manager.enable = true;
#   # programs.bash.enable = true;
#   programs.git.enable = true;
#   programs.bash = {
#     enable = true;
#     shellAliases = {
#       btw = "echo i use nixos, btw";
#     };
#     # profileExtra = ''
#     #   if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
#     #     exec uwsm start -S hyprland-uwsm.desktop
#     #   fi
#     # '';
#     profileExtra = ''
#       exec hyprland --config ~/.config/system/config/hypr/hyprland.conf
#     '';
#   };
#   # home.activation = {
#   #   linkDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
#   #     #!/usr/bin/env bash
#   #     link_config() {
#   #       local target=$1
#   #       local link=$2
#   #       mkdir -p "$(dirname "$link")"
#   #       if [ -e "$link" ] && [ ! -L "$link" ]; then
#   #         $DRY_RUN_CMD echo "Warning: $link exists and is not a symlink, skipping"
#   #       else
#   #         $DRY_RUN_CMD rm -f "$link"
#   #         $DRY_RUN_CMD ln -sf "$target" "$link"
#   #       fi
#   #     }
#   #     # -------------------------------------------------------------------------
#   #     #  MAKE SYMLINKS FROM DOTFILE LOCATIONS TO FILE LOCATIONS IN THIS GIT REPO
#   #     # -------------------------------------------------------------------------
#   #     link_config ~/.config/system/zshrc ~/.zshrc
#   #     # link_config ~/.config/system/ironbar ~/.config/ironbar
#   #   '';
#   # };
# }
{
  config,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "martinm";
  home.homeDirectory = "/home/martinm";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
