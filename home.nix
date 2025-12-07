{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "martinm";
  home.homeDirectory = "/home/martinm";
  home.stateVersion = "25.05";

  home.activation = {
    linkDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      #!/usr/bin/env bash

      link_config() {
        local target=$1
        local link=$2

        mkdir -p "$(dirname "$link")"

        if [ -e "$link" ] && [ ! -L "$link" ]; then
          $DRY_RUN_CMD echo "Warning: $link exists and is not a symlink, skipping"
        else
          $DRY_RUN_CMD rm -f "$link"
          $DRY_RUN_CMD ln -s "$target" "$link"
        fi
      }

      # -------------------------------------------------------------------------
      #  MAKE SYMLINKS FROM DOTFILE LOCATIONS TO FILE LOCATIONS IN THIS GIT REPO
      # -------------------------------------------------------------------------
      link_config ~/.config/system/zshrc ~/.zshrc
    '';
  };
}
