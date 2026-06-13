{
  config,
  pkgs,
  nixpkgsUnstable,
  ...
}: {
  environment.systemPackages = with pkgs; [
    nixpkgsUnstable.legacyPackages.x86_64-linux.super-productivity
    nixpkgsUnstable.legacyPackages.x86_64-linux.xournalpp # Xournal++; handwritten note-taking software (alternative to Microsoft OneNote)
    anki-bin # Anki (Spaced Repetition flashcard software); `anki-bin` is more up-to-date than `anki`
    nixpkgsUnstable.legacyPackages.x86_64-linux.godot
    obs-studio # OBS (screen recording)
  ];
}
