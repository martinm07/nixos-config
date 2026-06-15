{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  hyprland-custom-session =
    pkgs.runCommand "hyprland-custom-session" {
      # This is, the name of the .desktop file that is to define a session for the Display Manager,
      #  to be able to select and log in to.
      passthru.providedSessions = ["hyprland-custom"];
    } ''
      mkdir -p $out/share/wayland-sessions $out/bin

      # Wrapper script that logs and starts Hyprland
      # For whatever reason, simply calling Hyprland directly with something like
      #  Hyprland --config "$HOME/.config/system/config/hypr/hyprland.conf"
      # ...in the Exec field, fails. Firstly, it seems possible that the
      #  "Desktop Entry Parser" doesn't understand env variables like $HOME-
      #  or that in general; it doesn't execute in a full shell environment.
      # Secondly, if you try to still execute it inline by putting something like
      #  sh -c "Hyprland --config /home/martinm/.config/system/config/hypr/hyprland.conf"
      # ...in the Exec field, it still fails. Possibly it crashes without some env variables,
      #  possibly it doesn't properly spawn a long-running process- instead exiting right away,
      #  possibly the "Desktop Entry Parser" doesn't like something about the quotes, or something
      #  about the escaping.
      cat > $out/bin/hyprland-custom <<'EOS'
      #!/bin/sh
      LOG="$HOME/.local/share/hyprland/hyprland-launch.log"
      mkdir -p "$(dirname "$LOG")"
      echo "---- hyprland-start $(date) ----" >> "$LOG"
      echo "ENV:" >> "$LOG"
      env >> "$LOG"
      echo "---- start Hyprland ----" >> "$LOG"
      exec start-hyprland -- --config "$HOME/.config/system/config/hypr/hyprland.lua" >> "$LOG" 2>&1
      EOS
      chmod +x $out/bin/hyprland-custom

      cat > $out/share/wayland-sessions/hyprland-custom.desktop <<EOF
      [Desktop Entry]
      Name=Hyprland Custom
      Comment=Hyprland with custom config
      Exec=$out/bin/hyprland-custom
      Type=Application
      DesktopNames=Hyprland
      Keywords=tiling;wayland;compositor;
      EOF
    '';

  cfg = config.myc.boot;
in {
  options.myc.boot = {
    enableGRUB = lib.mkEnableOption "Enables GRUB with EFI support";
    enableSDDM = lib.mkEnableOption "Enables the SDDM display manager";
    addHyprlandCustomDM = lib.mkEnableOption "Adds hyprland-custom session file for launching hyprland with a custom config location";
  };

  config = mkMerge [
    ### Bootloader
    ##############

    (mkIf cfg.enableGRUB {
      # boot.loader.systemd-boot.enable = true;
      # boot.loader.efi.canTouchEfiVariables = true;
      boot.loader = {
        grub = {
          enable = true;
          efiSupport = true;
          useOSProber = true;
          configurationLimit = 120;
          # All of this bootloader stuff still goes over my head, but it seems like
          # this "device" option asks NixOS to install GRUB in BIOS mode, whereas we're using UEFI boot
          # Specifying a disk partition here will have NixOS attempt to install GRUB to my SSD's "Master Boot Record" (MBR)
          # Specifying `boot.loader.grub.efiSupport` to true will have NixOS attempt to install the UEFI GRUB binary to `/boot/EFI/nixos`
          device = "nodev";
        };
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
      };
    })

    ### Display Manager
    ###################

    # The "displayManager" refers to the login screen. LightDM is the default for NixOS
    (mkIf cfg.enableSDDM {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
    })

    # Create a custom Hyprland session with your config path
    (mkIf cfg.addHyprlandCustomDM {
      services.displayManager = {
        sessionPackages = [hyprland-custom-session];
        defaultSession = "hyprland-custom";
      };
    })

    {
      # Enable automatic login for the user.
      # With automatic login, the first application you open triggers polkit to ask for the password
      # If you provide the password in the display manager the keyring is automatically unlocked
      # And even with autoLogin enabled, the display manager still exists and will ask for a password after
      #  inactivity, turning on the system, etc.
      # https://askubuntu.com/questions/1376042/at-startup-access-to-the-default-keyring-is-required-by-an-application
      services.displayManager.autoLogin.enable = false;
      # services.displayManager.autoLogin.user = "martinm";
    }
  ];
}
