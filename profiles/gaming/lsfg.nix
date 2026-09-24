{ self }:
{
  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      lsfgVk = self.packages.${pkgs.system}.lsfg-vk;

      losslessScalingDll = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/Lossless Scaling/lsfg-vk.dll";

      profiles = {
        "2x" = {
          multiplier = 2;
          flowScale = "1.0";
          performanceMode = false;
        };

        "3x" = {
          multiplier = 3;
          flowScale = "1.0";
          performanceMode = false;
        };

        "4x" = {
          multiplier = 4;
          flowScale = "1.0";
          performanceMode = false;
        };
      };

      mkLsfgLauncher =
        profileName: profile:
        pkgs.writeShellScriptBin "lsfg-vk-${profileName}" ''
          set -eu

          if [ "$#" -eq 0 ]; then
            printf 'usage: %s <executable> [arguments...]\n' "$0" >&2
            exit 1
          fi

          export VK_ADD_IMPLICIT_LAYER_PATH="${lsfgVk}/share/vulkan/implicit_layer.d''${VK_ADD_IMPLICIT_LAYER_PATH:+:$VK_ADD_IMPLICIT_LAYER_PATH}"
          export LSFGVK_ENV=1
          export LSFGVK_DLL_PATH="${losslessScalingDll}"
          export LSFGVK_MULTIPLIER="${toString profile.multiplier}"
          export LSFGVK_FLOW_SCALE="${profile.flowScale}"
          export LSFGVK_PERFORMANCE_MODE="${if profile.performanceMode then "1" else "0"}"

          exec "$@"
        '';

      launchers = lib.mapAttrsToList mkLsfgLauncher profiles;
    in
    {
      home.packages = launchers;
    };
}
