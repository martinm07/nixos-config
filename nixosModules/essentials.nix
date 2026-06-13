{
  config,
  pkgs,
  # hostname, ## IMP: Extra input required for hostname; like "dm01" or "m02"
  lib,
  ...
}:
with lib; {
  options.myc = {
    hostname = mkOption {
      type = types.str;
      description = "Hostname for this machine.";
    };
  };

  config = mkMerge [
    {
      ### NETWORK
      ###########

      networking.hostName = config.myc.hostname;

      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Enable networking
      networking.networkmanager.enable = true;

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      networking.firewall.enable = false;

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
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

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
  ];
}
