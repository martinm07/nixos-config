{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myc.gaming;
in {
  options.myc.gaming = {
    enableWaydroid = lib.mkEnableOption "Adds Waydroid for android virtualisation";
    enableNVTOPAMD = lib.mkEnableOption "Adds nvtopPackages.amd for monitoring GPU utilisation";
    enableNVTOPNvidia = lib.mkEnableOption "Adds nvtopPackages.nvidia for monitoring GPU utilisation";
  };

  config = mkMerge [
    (mkIf cfg.enableWaydroid {
      virtualisation.waydroid.enable = true;
    })

    (mkIf cfg.enableNVTOPAMD {
      environment.systemPackages = with pkgs; [nvtopPackages.amd];
    })

    (mkIf cfg.enableNVTOPNvidia {
      environment.systemPackages = with pkgs; [nvtopPackages.nvidia];
    })

    {
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

      environment.systemPackages = with pkgs; [
        lact # GPU controller GUI
        vulkan-tools # Provides 'vulkaninfo' and 'vkcube' commands

        # --- --- --- --
        # --- GAMING ---
        # --- --- --- --
        protonup-ng # Provides a CLI command `protonup` which installs the latest version of Proton GE
        #          This is so that Steam can use Proton GE to launch games (instead of Valve's official Proton releases).
        #          That is also the purpose of setting STEAM_EXTRA_COMPAT_TOOLS_PATHS in environment.sessionVariables later down
        #           (so that on Steam it appears under [selected game] > Properties... > Compatibility)
        #          TODO: Not necessary if using Heroic launcher as primary launcher for games...?

        hydralauncher # For getting download sources
        heroic # Primary games launcher
        prismlauncher # Minecraft launcher

        mangohud # Provides a small HUD on games for monitoring FPS, system resources, etc.
        qbittorrent # For managing torrents (I find it the nicest and most feauture-complete; especially of value being the ability to "Force recheck")
        wineWowPackages.stable # support both 32-bit and 64-bit applications
        winetricks # for installing missing DLLs and other configuration
        osu-lazer-bin
        waydroid-helper
      ];

      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      };
    }
  ];
}
