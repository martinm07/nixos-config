{
  config,
  pkgs,
  # hostname, ## IMP: Extra input required for hostname; like "dm01" or "m02"
  lib,
  ...
}:
with lib; let
  cfg = config.myc.essentials;
in {
  options.myc = {
    hostname = mkOption {
      type = types.str;
      description = "Hostname for this machine.";
    };

    essentials = {
      enableBattery = lib.mkEnableOption "Enables UPower, a DBus service for power management.";
    };
  };

  config = mkMerge [
    {
      environment.sessionVariables = {
        NIXOS_HOST = config.myc.hostname;
      };

      ### NETWORK
      ###########

      networking.hostName = config.myc.hostname;

      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Enable networking
      networking.networkmanager.enable = true;

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Open ports in the firewall.
      networking.firewall.allowedTCPPorts = [53317];
      networking.firewall.allowedUDPPorts = [53317];

      ### AUDIO
      #########

      services.pulseaudio.enable = false; ## DISABLE PulseAudio; the older audio framework that pipewire replaces.

      # Enable sound with pipewire.
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      ### BLUETOOTH
      #############

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
    }

    (mkIf cfg.enableBattery {
      services.upower.enable = true;
    })

    (mkIf config.myc.audio.enableLiveAudioMixing {
      services.pipewire = {
        jack.enable = true;
        extraConfig.pipewire."92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 32;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 32;
          };
        };
      };
    })
  ];
}
