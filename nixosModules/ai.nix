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
    enableOllama = lib.mkEnableOption "Enables Ollama";
    enableLLamaCpp = lib.mkEnableOption "Enables Llama.cpp";
    iGPUDisplay = lib.mkEnableOption "Configures the iGPU (in the 9700X) for video output, leaving the dedicated graphics (7900XTX) for compute";
  };

  config = mkMerge [
    (mkIf cfg.enableOllama {
      # Creating a symlink for the ROCm HIP libraries where most applications expect them
      # https://nixos.wiki/wiki/AMD_GPU#HIP
      # systemd.tmpfiles.rules = [
      #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
      # ];

      # Enable the native Ollama background service
      services.ollama = {
        enable = true;
        # loadModels = ["gemma4:26b" "gemma4:31b"];

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

    (mkIf cfg.enableLLamaCpp {
      services.llama-cpp = {
        enable = true;
        # package = pkgs.llama-cpp-vulkan;
        # package = (pkgs.llama-cpp.override { cudaSupport = true; })
        package = nixpkgsUnstable.legacyPackages.x86_64-linux.llama-cpp-vulkan;

        extraFlags = [
          "--ctx-size"
          "135000"

          "--n-gpu-layers"
          "99"

          "--parallel"
          "1"
          # Flash attention is an "algorithm to make training/inference faster" (default 'auto')
          "--flash-attn"
          "on"
          # Data type for the KV cache (default 'f16')
          "--cache-type-k"
          "q8_0"

          "--cache-type-v"
          "q8_0"
          # Physics maximum batch size (buffer during inference; lower to save VRAM) (default '512')
          "--ubatch-size"
          "512"
          # Whether to use Jinja templating
          "--jinja"

          "--no-mmproj"

          "-dev"
          "Vulkan1"

          "-sm"
          "none"
        ];

        # Takes care of downloading if model not present
        modelsPreset = {
          # # Requires 8GB VRAM
          # "LFM2.5-8B-A1B" = {
          #   hf-repo = "unsloth/LFM2.5-8B-A1B-GGUF";
          #   hf-file = "LFM2.5-8B-A1B-UD-Q4_K_XL.gguf";
          #   alias = "unsloth/LFM2.5-8B-A1B-GGUF";
          #   temp = "0.2";
          #   repeat-penalty = "1.05";
          #   top-k = "80";
          # };
          # # Requires 56GB VRAM
          # "Qwen3-Coder-Next" = {
          #   hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
          #   hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
          #   alias = "unsloth/Qwen3-Coder-Next";
          #   temp = "1.0";
          #   top-p = "0.95";
          #   top-k = "40";
          # };
          # "Qwen3.8-27B-(DavidAU)" = {
          #   hf-repo = "DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF";
          #   hf-file = "Qwen3.8-27B-TurboFCFusion-735-882-Here-Uncen-NEO-CODER-MAX-MTP-Q4_K_M.gguf";
          #   alias="DavidAU/Qwen3.8-27B-(DavidAU)";

          # };

          "Qwen3.8-27B" = {
            hf-repo = "unsloth/Qwen3.8-27B-GGUF";
            hf-file = "Qwen3.8-27B-UD-Q4_K_M.gguf";
            alias = "unsloth/Qwen3.8-27B";

            ctx-size = 135000;

            temp = 1.0;
            top-p = 0.95;
            top-k = 20;
            min-p = 0.0;
            # Default (other options are "medium" and "low"; https://unsloth.ai/docs/models/qwen3.8#thinking--preserve-thinking)
            # chat-template-kwargs = {
            #   reasoning_effort = "xhigh";
            #   preserve_thinking = true;
            # };

            chat-template-kwargs = ''{"reasoning_effort": "xhigh", "preserve_thinking": true}'';
          };
        };
      };

      environment.systemPackages = [nixpkgsUnstable.legacyPackages.x86_64-linux.pkgs.llama-cpp-vulkan];
    })

    (mkIf cfg.iGPUDisplay {
      # These use the vendor and device IDs specific to the AMD 9700X CPU and 7900XTX GPU.
      # They associate these with symlinks to /dev/dri/igpu and /dev/dri/dgpu respectively, giving named anchors to both devices
      services.udev.extraRules = ''
        SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNEL!="card[0-9]*-*", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x13c0", SYMLINK+="dri/igpu"
        SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNEL!="card[0-9]*-*", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x744c", SYMLINK+="dri/dgpu"
      '';

      environment.systemPackages = [
        (pkgs.writeShellScriptBin "gpu-mode" ''
          f="$HOME/.config/hypr/gpu.lua"
          mkdir -p "$(dirname "$f")"
          case "$1" in
            igpu) echo 'hl.env("AQ_DRM_DEVICES", "/dev/dri/igpu")' > "$f" ;;
            dgpu) echo 'hl.env("AQ_DRM_DEVICES", "/dev/dri/dgpu:/dev/dri/igpu")' > "$f" ;;
            *) echo "usage: gpu-mode igpu|dgpu" >&2; exit 1 ;;
          esac
          echo "Set to $1. Log out and back in to apply."
        '')
      ];
    })

    {
      # Bubblewrap (bwrap) is used by Zed for basic agent sandboxing
      environment.systemPackages = with pkgs; [bubblewrap];
    }
  ];
}
