{
  config,
  pkgs,
  ...
}: {
  programs.nh = {
    enable = true;
    flake = "/home/martinm/.config/system";
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.flatpak.enable = true;

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [
    # Includes packages that imperative DLLs (for example, downloaded by Zed extensions) are asking to have exist
    #  in the library path.
  ];

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nh-os-switch" ''
      set -euo pipefail

      # Get git information
      COMMIT_HASH=$(${git}/bin/git -C /home/martinm/.config/system rev-parse --short HEAD 2>/dev/null || echo "unknown")
      COMMIT_MSG=$(${git}/bin/git -C /home/martinm/.config/system log -1 --pretty=format:"%s" 2>/dev/null || echo "no-git-info")

      # Truncate message if too long (bootloader has limited space)
      if [ ''${#COMMIT_MSG} -gt 50 ]; then
        COMMIT_MSG="''${COMMIT_MSG:0:47}..."
      fi

      # Build the raw label (hash + colon + space + message)
      RAW_LABEL="''${COMMIT_HASH}_:_''${COMMIT_MSG}"

      # 1) Replace spaces with hyphens
      # 2) Remove any character not in A–Za–z0–9 : _ . -
      SANITIZED_LABEL=$(printf '%s' "$RAW_LABEL" \
        | tr ' ' '-' \
        | tr -cd 'A-Za-z0-9:_.-')

      echo "Building with label: $SANITIZED_LABEL"

      # Export it for nixos-rebuild
      export NIXOS_LABEL="$SANITIZED_LABEL"

      # Check if user already provided -- separator
      if [[ " $* " == *" -- "* ]]; then
      #     # User provided --, append our option to their extra args
        ${nh}/bin/nh os switch "$@" --impure
      else
      #     # No -- from user, add our own
        ${nh}/bin/nh os switch "$@" -- --impure
      fi
    '')
  ];
}
