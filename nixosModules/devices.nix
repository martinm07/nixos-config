{
  config,
  pkgs,
  ...
}: {
  ### AMD GPU
  ###########

  # LACT is a GUI interface for controlling amdgpu
  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"]; # start the daemon on boot

  boot.initrd.kernelModules = ["amdgpu"]; # Load the correct driver "right away"
  services.xserver.videoDrivers = ["amdgpu"];

  environment.systemPackages = with pkgs; [
    lact # GUI amdgpu controller

    ### LOGITECH GAMING MOUSE
    #########################

    libratbag # Handling my Logitech mouse
    piper # GUI for libratbag
  ];

  ### WACOM DRAWING TABLET
  ########################

  # Driver for Wacom Drawing Tablet, that should support emulating mouse input using the tablet, for certain applications that require it
  hardware.opentabletdriver.enable = true;
  # Required by OpenTabletDriver
  hardware.uinput.enable = true; # "uinput makes it possible to emulate input devices from user space" (probably stands for "user input")
  boot.kernelModules = ["uinput"];
}
