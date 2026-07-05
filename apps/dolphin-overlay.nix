{
  pkgs,
  symlinkJoin,
  makeWrapper,
  ...
}: let
  k = pkgs.kdePackages;
  menuDir = pkgs.runCommand "dolphin-menu" {} ''
    mkdir -p $out/etc/xdg/menus
    cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out/etc/xdg/menus/applications.menu
  '';
  dolphinPluginsFixed = k.dolphin-plugins.overrideAttrs (old: {
    buildInputs =
      (old.buildInputs or [])
      ++ [
        k.dolphin
      ];
    nativeBuildInputs =
      (old.nativeBuildInputs or [])
      ++ [
        k.extra-cmake-modules
      ];

    cmakeFlags =
      (old.cmakeFlags or [])
      ++ [
        "-DDolphinVcs_DIR=${k.dolphin}/lib/cmake/DolphinVcs"
      ];
  });
  baseDolphin = k.dolphin;
  dolphin = symlinkJoin {
    name = "dolphin";
    pname = "dolphin";
    version = baseDolphin.version or "unknown";

    paths = [
      baseDolphin
      dolphinPluginsFixed
    ];
    nativeBuildInputs = [makeWrapper];
    postBuild = ''
      rm $out/bin/dolphin
      makeWrapper ${baseDolphin}/bin/dolphin $out/bin/dolphin \
        --set XDG_CONFIG_DIRS "${menuDir}/etc/xdg:$XDG_CONFIG_DIRS" \
        --run "${k.kservice}/bin/kbuildsycoca6 --noincremental ${menuDir}/etc/xdg/menus/applications.menu"
    '';
    meta =
      baseDolphin.meta
      // {
        description = "Dolphin with plugins + fixed menu + wrapper";
      };
  };
in
  dolphin
