{
  config,
  pkgs,
  ...
}: {
  i18n.inputMethod = {
    enable = true;
    # type = "ibus";
    # ibus.engines = with pkgs.ibus-engines; [mozc];
    type = "fcitx5";
    fcitx5.addons = with pkgs; [fcitx5-mozc fcitx5-gtk];
    fcitx5.waylandFrontend = true;
  };

  environment.variables = {
    ## It was necessary to "unset" these env variables for IBus to work somewhat.
    ## Now we're using fcitx5 which is much better behaved, but it's useful to know how to unset env variables reliably (shown here with lib.mkForce and an empty string)
    # GTK_IM_MODULE = lib.mkForce "";
    # QT_IM_MODULE = lib.mkForce "wayland";

    # Keep XMODIFIERS set to ibus so XWayland apps (like Steam or old apps) still work.
    # The IBus module usually sets this automatically, but you can be explicit if you want.
    XMODIFIERS = "@im=fcitx";
  };

  #########################
  ## TODO: Still necessary?

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "extd";
  };

  # Configure console keymap
  console.keyMap = "uk";

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
}
