{
  config,
  pkgs,
  ...
}: {
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts
      ubuntu-classic
      fira-code
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [
          "Noto Sans CJK JP"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK HK"
          "Noto Sans CJK KR"
          "Noto Sans"
        ];
        serif = [
          "Noto Serif CJK JP"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK HK"
          "Noto Serif CJK KR"
          "Noto Serif"
        ];
        monospace = ["Ubuntu Mono"];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    texliveFull # For enabling LaTeX (this adds a LOT of stuff to the system)
  ];
}
