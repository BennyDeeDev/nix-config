{ self }:
{
  homeManager =
    {
      config,
      pkgs,
      ...
    }:
    let
      lsfgVk = self.packages.${pkgs.system}.lsfg-vk;
      eden = config.my.gaming.edenPackage;
      edenName = eden.meta.mainProgram;
      losslessScalingDll = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/Lossless Scaling/lsfg-vk.dll";
      edenWithLsfg = pkgs.writeShellScriptBin "${edenName}-lsfg" ''
        set -eu

        export VK_ADD_IMPLICIT_LAYER_PATH="${lsfgVk}/share/vulkan/implicit_layer.d''${VK_ADD_IMPLICIT_LAYER_PATH:+:$VK_ADD_IMPLICIT_LAYER_PATH}"
        export LSFGVK_ENV=1
        export LSFGVK_DLL_PATH="${losslessScalingDll}"
        export LSFGVK_MULTIPLIER=2
        export LSFGVK_FLOW_SCALE=1.0
        export LSFGVK_PERFORMANCE_MODE=0

        exec "${eden}/bin/${edenName}" "$@"
      '';
    in
    {
      home.packages = [
        eden
        edenWithLsfg
      ];
    };
}
