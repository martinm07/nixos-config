# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  nixpkgsUnstable,
  inputs,
  lib,
  # self,
  ...
}: let
  hostname = "dm01";
  linkedApp = import ./apps/linked-derivation.nix {inherit pkgs;};

  # When finding what this actually produces, you need to go to /nix/store and find the entry of
  # "hyprland-custom-session" that is actually active. To do that there is this very helpful command:
  #      nix-store --query --requisites /run/current-system | grep hyprland
  # Essentially, it gets the closure of the current system (that is what "requisites" means), and filters the output by the keyword "hyprland"
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
      exec Hyprland --config "$HOME/.config/system/config/hypr/hyprland.conf" >> "$LOG" 2>&1
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
in {
  # system.configurationRevision = src.rev;
  # system.nixos.label = "commit: ${self.sourceInfo.shortRev}";
  networking.hostName = hostname;
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  programs.nh = {
    enable = true;
    flake = "/home/martinm/.config/system";
  };

  # Bootloader.
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

  # networking.hostName = "nixos"; # Define your hostname
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "spotify"
      "steam"
      "steam-unwrapped"
      "ticktick"
      "obsidian"
      "google-chrome"
      "zoom-us"
      "zoom"
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Dublin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_IE.UTF-8";
  };

  i18n.inputMethod = {
    enable = true;
    # type = "ibus";
    # ibus.engines = with pkgs.ibus-engines; [mozc];
    type = "fcitx5";
    fcitx5.addons = with pkgs; [fcitx5-mozc fcitx5-gtk];
    fcitx5.waylandFrontend = true;
  };

  environment.variables = {
    # Force GTK_IM_MODULE to be empty to prevent GTK apps from using IBus legacy code.
    # They will auto-detect Wayland and use the text-input protocol instead.
    GTK_IM_MODULE = lib.mkForce "";

    # For QT, "wayland" is usually the best setting on Hyprland, provided you have
    # qt5.qtwayland and qt6.qtwayland installed.
    # If that causes issues, you can set this to "" (empty) as well.
    QT_IM_MODULE = lib.mkForce "wayland";

    # Keep XMODIFIERS set to ibus so XWayland apps (like Steam or old apps) still work.
    # The IBus module usually sets this automatically, but you can be explicit if you want.
    XMODIFIERS = "@im=fcitx";
  };

  # systemd.user.services."ibus-wayland" = {
  #   description = "IBus (Wayland) UI + daemon (start as child)";
  #   wantedBy = ["default.target"];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.coreutils}/bin/env -u GTK_IM_MODULE -u QT_IM_MODULE ${pkgs.ibus}/libexec/ibus-ui-gtk3 --enable-wayland-im --exec-daemon --daemon-args \"--xim --panel disable\"";
  #     Restart = "on-failure";
  #     RestartSec = "2s";
  #   };
  # };

  # This is additional config, for mapping CapsLock to "Eisu toggle" on the Japanese keyboard
  #  (essentially, just getting alphanumeric lettering; katakana is achieved by holding Shift)
  # And separately for mapping the backtick from a "dead_grave" to a "grave"
  #  (so that I only have to press it once to type)
  # Where the backtick mapping comes from: https://gist.github.com/keckelt/0ba90f8840e2903bfdc54c7e19ad4613
  # More info on keyboard keycode mapping with xmodmap: https://chatgpt.com/share/688a93b8-7dbc-8002-94f0-1840096aab22
  # This is supposed to run on startup. Taken from here: https://nixos.wiki/wiki/Keyboard_Layout_Customization
  # TODO: This doesn't do anything on a Wayland setup.
  services.xserver.displayManager.sessionCommands = ''sleep 5 && ${pkgs.xorg.xmodmap}/bin/xmodmap ${pkgs.writeText "keymap-mod" ''
      keycode 66 = Eisu_toggle Caps_Lock
      keycode  49 = grave notsign dead_grave notsign brokenbar notsign brokenbar
      clear Lock
    ''}'';

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      ubuntu-classic
      fira-code
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = ["Noto Sans CJK"];
        serif = ["Noto Serif CJK"];
        monospace = ["Ubuntu Mono"];
      };
    };
  };

  # Enable the X11 windowing system (but also Wayland? See https://github.com/NixOS/nixpkgs/issues/94799)
  services.xserver.enable = true;

  # Enabling support for Wacom drawing tablet (model Intuos PTH-451)
  services.xserver.wacom.enable = true;

  # The "displayManager" refers to the lockscreen. LightDM is the default for NixOS
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Create a custom Hyprland session with your config path
  services.displayManager.sessionPackages = [hyprland-custom-session];
  services.displayManager.defaultSession = "hyprland-custom";

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

  environment.budgie.excludePackages = [
    pkgs.gnome-terminal
  ];
  services.xserver.excludePackages = [pkgs.xterm];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "extd";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # https://nixos.wiki/wiki/Printing
  # Enable CUPS to print documents (NOTE: this allows printer management through http://localhost:631)
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [hplip];

  # https://nixos.wiki/wiki/Scanners
  hardware.sane.enable = true;
  # "sane-airscan" is for "driverless" scanning
  hardware.sane.extraBackends = [pkgs.sane-airscan];

  # For scanner discovery by other programs; udev assigns "predictable names" to network interfaces
  # services.udev.packages = [pkgs.sane-airscan];

  # Allow printer discovery on local network
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # To add the HP OfficeJet Pro 7740 printer requires using the unfree 'hp-setup' GUI included in
  #  'pkgs.hplipWithPlugin'. So, we can do a one-time installation using nix-shell:
  # NIXPKGS_ALLOW_UNFREE=1 nix-shell -p hplipWithPlugin --run 'sudo -E hp-setup'
  #   And then it is automatically recognized by CUPS, it saves the PPD file under /etc/cups/ppd, and
  #   everything should be fine (including after collecting garbage in the Nix store).

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.martinm = {
    isNormalUser = true;
    description = "Martin Molnar";
    # "lp" is a group for "scanner printers" (i.e. all-in-one printers) I believe
    extraGroups = ["networkmanager" "wheel" "input" "docker" "scanner" "lp"];
    packages = with pkgs; [
      thunderbird
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    # plugins = [];
    customPkgs = with pkgs; [zsh-fzf-tab];
  };

  # Enable automatic login for the user.
  # With automatic login, the first application you open triggers polkit to ask for the password
  # If you provide the password in the display manager the keyring is automatically unlocked
  # And even with autoLogin enabled, the display manager still exists and will ask for a password after
  #  inactivity, turning on the system, etc.
  # https://askubuntu.com/questions/1376042/at-startup-access-to-the-default-keyring-is-required-by-an-application
  services.displayManager.autoLogin.enable = false;
  # services.displayManager.autoLogin.user = "martinm";

  programs.firefox.enable = true;

  services.flatpak.enable = true;
  virtualisation.docker.enable = true;
  services.mysql = {
    enable = true;
    package = pkgs.mysql84;
  };

  # environment.pathsToLink = [ "/home/martinm/.local/share/gem/ruby" ];
  # environment.variables.PATH = ;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # --- --- ---- --- ---
    # --- SYSTEM TOOLS ---
    # --- --- ---- --- ---
    wget
    gtop
    eza # A Rust alternative to ls/tree. Output uses colours (based on a theme) to include extra information.
    #     For info on the default theme:   https://github.com/eza-community/eza/blob/main/docs/theme.yml
    xorg.xmodmap
    clinfo # Verifying that OpenCL is correctly set up
    lact # GUI amdgpu controller
    vulkan-tools # Provides 'vulkaninfo' and 'vkcube' commands
    libratbag # Handling my Logitech mouse
    piper # GUI for libratbag

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

    # --- --- --- --- --- ---
    # --- DEVELOPER TOOLS ---
    # --- --- --- --- --- ---
    kitty
    vim
    # There's also `zed-editor-fhs` for wrapping the editor in a Filesystem Hierarchy Standard (FHS) sandbox, allegedly
    #  for allowing extensions to work without Nix-specific configuration. These are extensions that try to run
    #  dynamically linked libraries (DLLs) e.g. that are language servers (like rust-analyzer): https://github.com/NixOS/nixpkgs/issues/309662
    # Refer to this for the use-cases of an FHS wrapper: https://nixos.org/manual/nixpkgs/stable/#sec-fhs-environments
    # However, this does create inconvenciences, like the Zed terminal running isolated from the regular system, missing everything not
    #  in the user directory like /etc, /nix/store, etc. and missing certain privelages. As well as some funky stuff potentially freezing the system
    #  (TODO: waiting to see if that happens again after switching off of zed-editor-fhs)
    #  and not getting PATH updates after system version switches (just speculation, though).
    # I'm pretty sure the problem with DLLs can also be fixed by using programs.nix-ld. Try to use that before switching back to zed-editor-fhs.
    #
    # From what I read there also seems to be another issue with `zed-editor` (not -fhs) where during installing it tries to install some default pre-built LSPs
    #  into ~/.local/share/zed/languages/ (especially a JSON LSP for editing Zed's settings.json) and fails to do that because of Nix.
    # Since I started with zed-editor-fhs I got these files in my home directory, and after that the regular `zed-editor` was fine (i.e. I got lucky :))
    # See:   https://github.com/NixOS/nixpkgs/issues/421750     and:   https://wiki.nixos.org/wiki/Zed#LSP_Support
    nixpkgsUnstable.legacyPackages.x86_64-linux.zed-editor
    nixd # Nix LSP
    alejandra # Nix formatter
    (python313.withPackages (
      ps:
        with ps; [
          flask
          flask-wtf
          wtforms
          twilio
          regex
        ]
    ))
    uv
    nodejs
    baobab

    # --- --- ---- ---
    # --- HYPRLAND ---
    # --- --- ---- ---

    ironbar # Status bar
    wpaperd # Wallpaper manager
    swaynotificationcenter # SwayNC (notification manager that should also work with Hyprland)
    libnotify # Package that dunst depends on (TODO: Does SwayNC depend on it?)
    rofi # App launcher
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    paper-gtk-theme

    kdePackages.dolphin # File browser
    mate.pluma # Text editor
    qalculate-gtk # Calculator (that is very cool)
    vlc # Video viewer/playback
    swayimg # Image viewer

    pwvucontrol # Small audio controller/manager application
    nwg-displays # Small display manager application
    btop # System resources TUI
    networkmanagerapplet # Network manager

    kdePackages.breeze-icons

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
    nvtopPackages.amd # For monitoring GPU utilisation
    qbittorrent # For managing torrents (I find it the nicest and most feauture-complete; especially of value being the ability to "Force recheck")
    wineWowPackages.stable # support both 32-bit and 64-bit applications
    winetricks # for installing missing DLLs and other configuration

    # --- --- --- --- ---
    # --- CASUAL APPS ---
    # --- --- --- --- ---
    discord
    element-desktop # Matrix client
    spotify
    naps2 # Scanning software
    libreoffice-fresh
    ticktick
    nixpkgsUnstable.legacyPackages.x86_64-linux.super-productivity # Trialing this is an alternative to TickTick
    linkedApp # Trialing this to replace TickTick's habit log
    obsidian
    calibre
    nixpkgsUnstable.legacyPackages.x86_64-linux.xournalpp # Xournal++; handwritten note-taking software (alternative to Microsoft OneNote)
    texliveFull # For enabling LaTeX (this adds a LOT of stuff to the system)
    anki-bin # Anki (Spaced Repetition flashcard software); `anki-bin` is more up-to-date than `anki`
    google-chrome # Mainly for NativShark, which is almost unusable on Firefox thanks to audio tracks sporatically not loading
    nixpkgsUnstable.legacyPackages.x86_64-linux.godot
    darktable
    zoom-us
  ];

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

  boot.initrd.kernelModules = ["amdgpu"]; # Load the correct driver "right away"
  services.xserver.videoDrivers = ["amdgpu"];

  # Creating a symlink for the ROCm HIP libraries where most applications expect them
  # https://nixos.wiki/wiki/AMD_GPU#HIP
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # LACT is a GUI interface for controlling amdgpu
  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"]; # start the daemon on boot

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    # Hint for electron apps to use wayland compositor
    NIXOS_OZONE_WL = "1";

    # GTK_IM_MODULE = null;
    # QT_IM_MODULE = null;
  };

  programs.git.enable = true;
  programs.git.config = {
    user.name = "martinm07";
    user.email = "martin.github07@gmail.com";
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [
    # Includes packages that imperative DLLs (for example, downloaded by Zed extensions) are asking to have exist
    #  in the library path.
  ];

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
