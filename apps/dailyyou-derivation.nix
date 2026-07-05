{pkgs, ...}: let
  pubspecLock = pkgs.lib.importJSON ./dailyyou-pubspec.lock.json;
in
  pkgs.flutter341.buildFlutterApplication {
    pname = "daily_you";
    version = "2.26.0";

    src = pkgs.fetchFromGitHub {
      owner = "Demizo";
      repo = "Daily_You";
      rev = "v2.26.0";
      hash = "sha256-5dvtfs9otyg5pM1OdyAOH12+qjFUCSrWdVRfhEeHm/8=";
    };

    inherit pubspecLock;
    targetFlutterPlatform = "linux";

    gitHashes = {
      shared_storage = "sha256-0Hqm++hq2PXLXllR4ormXUIjICc5FOJImcU5LTJv6z0=";
    };

    nativeBuildInputs = with pkgs; [pkg-config wrapGAppsHook3 copyDesktopItems];
    buildInputs = with pkgs; [gtk3 sqlite gsettings-desktop-schemas];

    desktopItems = [
      (pkgs.makeDesktopItem {
        # Matches the CMakeLists.txt APPLICATION_ID, so Wayland/GNOME
        # correctly associates the running window with this launcher entry.
        name = "com.demizo.daily_you";
        desktopName = "Daily You";
        comment = "A private, offline-first journaling app";
        exec = "daily_you";
        icon = "com.demizo.daily_you";
        categories = ["Office" "Utility"];
        startupWMClass = "com.demizo.daily_you";
        terminal = false;
      })
    ];

    postInstall = ''
      install -Dm644 $src/assets/logo.png \
        $out/share/icons/hicolor/1024x1024/apps/com.demizo.daily_you.png
    '';

    meta = with pkgs.lib; {
      description = "A private, offline-first journaling app";
      homepage = "https://github.com/Demizo/Daily_You";
      license = licenses.gpl3Only;
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = "daily_you";
    };
  }
