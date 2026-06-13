{
  config,
  pkgs,
  nixpkgsUnstable,
  lib,
  ...
}:
with lib; let
  cfg = config.myc.ai;
in {
  options.myc.ai = {
    enable = lib.mkEnableOption "Enables Ollama";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Creating a symlink for the ROCm HIP libraries where most applications expect them
      # https://nixos.wiki/wiki/AMD_GPU#HIP
      # systemd.tmpfiles.rules = [
      #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
      # ];

      # Enable the native Ollama background service
      services.ollama = {
        enable = true;
        loadModels = ["gemma4:26b" "gemma4:31b"];

        # Point the service directly to your unstable rocm-enabled package
        package = nixpkgsUnstable.legacyPackages.x86_64-linux.ollama-rocm;

        # Tell ROCm precisely what GPU architecture family to emulate for Tensile/rocBLAS matrix math
        rocmOverrideGfx = "11.0.0";

        # Ensure the service listens globally so external tools like Zed Agent can reach it
        # environmentVariables = {
        #   OLLAMA_HOST = "0.0.0.0:11434";
        # };
      };
    })
  ];
}
