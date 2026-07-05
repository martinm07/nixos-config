{
  lib,
  fetchFromGitHub,
  flutter327, # match a version nixpkgs actually ships; see note below
  pkg-config,
  gtk3,
  sqlite,
  gsettings-desktop-schemas,
  wrapGAppsHook3,
}: let
  pubspecLock = lib.importJSON ./pubspec.lock.json;
in
  flutter327.buildFlutterApplication {
    pname = "daily_you";
    version = "2.26.0";

    src = fetchFromGitHub {
      owner = "Demizo";
      repo = "Daily_You";
      rev = "v2.26.0"; # or a commit
      hash = lib.fakeHash; # nix build will tell you the real one
    };

    inherit pubspecLock;
    targetFlutterPlatform = "linux";

    gitHashes = {
      shared_storage = lib.fakeHash; # nix build will tell you the real one
    };

    nativeBuildInputs = [pkg-config wrapGAppsHook3];
    buildInputs = [gtk3 sqlite gsettings-desktop-schemas];

    meta = with lib; {
      description = "A private, offline-first journaling app";
      homepage = "https://github.com/Demizo/Daily_You";
      license = licenses.gpl3Only; # check the repo's actual license file
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = "daily_you";
    };
  }
