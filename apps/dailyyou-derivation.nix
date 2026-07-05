{pkgs, ...}: let
  pubspecLock = pkgs.lib.importJSON ./dailyyou-pubspec.lock.json;
in
  pkgs.flutter341.buildFlutterApplication {
    pname = "daily_you";
    version = "2.26.0";

    src = pkgs.fetchFromGitHub {
      owner = "Demizo";
      repo = "Daily_You";
      rev = "v2.26.0"; # or a commit
      hash = "sha256-5dvtfs9otyg5pM1OdyAOH12+qjFUCSrWdVRfhEeHm/8="; # nix build will tell you the real one
    };

    inherit pubspecLock;
    targetFlutterPlatform = "linux";

    gitHashes = {
      shared_storage = "sha256-0Hqm++hq2PXLXllR4ormXUIjICc5FOJImcU5LTJv6z0="; # nix build will tell you the real one
    };

    nativeBuildInputs = with pkgs; [pkg-config wrapGAppsHook3];
    buildInputs = with pkgs; [gtk3 sqlite gsettings-desktop-schemas];

    meta = with pkgs.lib; {
      description = "A private, offline-first journaling app";
      homepage = "https://github.com/Demizo/Daily_You";
      license = licenses.gpl3Only; # check the repo's actual license file
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = "daily_you";
    };
  }
