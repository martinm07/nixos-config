{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myc.devices;
in {
  options.myc.devices = {
    enableLogitechMouse = lib.mkEnableOption "Enables libratbag and adds piper for handling Logitech mice";
    enableDrawingTablet = lib.mkEnableOption "Enables opentabletdriver";
    enableLACT = lib.mkEnableOption "Enables LACT, a GUI for controlling GPUs";
    enableAMDGPU = lib.mkEnableOption "Configures system to load amdgpu driver";
    enableNvidiaGPU = lib.mkEnableOption "Configures system to load nvidia driver";
  };

  config = mkMerge [
    (mkIf cfg.enableLACT {
      # LACT is a GUI for controlling AMD, Intel and Nvidia GPUs
      systemd.packages = with pkgs; [lact];
      systemd.services.lactd.wantedBy = ["multi-user.target"]; # start the daemon on boot

      environment.systemPackages = with pkgs; [
        lact # GUI amdgpu controller
      ];
    })

    (mkIf cfg.enableLogitechMouse {
      ### LOGITECH GAMING MOUSE
      #########################
      environment.systemPackages = with pkgs; [
        libratbag # Handling my Logitech mouse
        piper # GUI for libratbag
      ];
    })

    (mkIf cfg.enableDrawingTablet {
      ### WACOM DRAWING TABLET
      ########################

      # Driver for Wacom Drawing Tablet, that should support emulating mouse input using the tablet, for certain applications that require it
      hardware.opentabletdriver.enable = true;
      # Required by OpenTabletDriver
      hardware.uinput.enable = true; # "uinput makes it possible to emulate input devices from user space" (probably stands for "user input")
      boot.kernelModules = ["uinput"];
    })

    (mkIf cfg.enableAMDGPU {
      ### AMD GPU
      ###########

      boot.initrd.kernelModules = ["amdgpu"]; # Load the correct driver "right away"
      services.xserver.videoDrivers = ["amdgpu"];
    })

    (mkIf cfg.enableNvidiaGPU {
      ### NVIDIA GeForce GTX 1650 Ti Mobile
      ### GPU Name: TU116
      ### Release year: 2020
      ### Architecture: Turing

      # Load nvidia driver for Xorg and Wayland
      services.xserver.videoDrivers = [
        "nvidia"
        "amdgpu"
      ];
      boot.initrd.kernelModules = ["amdgpu"]; # Load the correct driver "right away"

      hardware.nvidia = {
        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
        # of just the bare essentials.
        powerManagement.enable = false;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Legacy drivers (legacy_580 is the "latest legacy" currently) are those of the Pascal, Maxwell, or Kepler architectures or older.
        # The latest driver supports Turing, Ampere, Ada, Blackwell (i.e. the oldest architecture it still supports is Turing)
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      # Software for switching between integrated and dedicated graphics as needed (Nvidia Optimus PRIME)
      # Laptop has NVIDIA dedicated GPU with Bus ID 0000:01:00.0 (note this is hex)
      #    and has AMD integrated graphics with Bus ID 0000:05:00.0

      hardware.nvidia.prime = {
        # Make sure to use the correct Bus ID values for your system!
        nvidiaBusId = "PCI:1:0:0";
        amdgpuBusId = "PCI:5:0:0";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    })
  ];
}
