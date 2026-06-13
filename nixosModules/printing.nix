{
  config,
  pkgs,
  ...
}: {
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
}
