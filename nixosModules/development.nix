{
  config,
  pkgs,
  nixpkgsUnstable,
  ...
}: {
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    # plugins = [];
    customPkgs = with pkgs; [zsh-fzf-tab];
  };

  virtualisation.docker.enable = true;
  services.mysql = {
    enable = true;
    package = pkgs.mysql84;
  };

  environment.systemPackages = with pkgs; [
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
  ];

  services.xserver.excludePackages = [pkgs.xterm];

  programs.git.enable = true;
  programs.git.config = {
    user.name = "martinm07";
    user.email = "martin.github07@gmail.com";
  };
}
