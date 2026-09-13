{
  homeManager =
    {
      config,
      nixConfig,
      pkgs,
      ...
    }:
    let
      losslessScalingDll = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll";
      steamCommonDirectory = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common";
      layerJson = "${pkgs.lsfg-vk}/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json";
      configFile = "${nixConfig}/files/gaming/lsfg-vk/conf.toml";
    in
    {
      home.packages = [ pkgs.lsfg-vk ];
      home.sessionVariables.LSFG_DLL_PATH = losslessScalingDll;

      home.file.".config/lsfg-vk/conf.toml".source = config.lib.file.mkOutOfStoreSymlink configFile;

      services.flatpak.overrides = {
        "io.github.ryubing.Ryujinx" = {
          Context.filesystems = [
            "${nixConfig}/files/gaming/lsfg-vk:ro"
            "${steamCommonDirectory}:ro"
          ];
          Environment.LSFG_DLL_PATH = losslessScalingDll;
        };
        "com.usebottles.bottles" = {
          Context.filesystems = [
            "${nixConfig}/files/gaming/lsfg-vk:ro"
            "${steamCommonDirectory}:ro"
          ];
          Environment.LSFG_DLL_PATH = losslessScalingDll;
        };
      };

      home.file = {
        ".var/app/io.github.ryubing.Ryujinx/config/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json".source =
          layerJson;
        ".var/app/io.github.ryubing.Ryujinx/config/lsfg-vk/conf.toml".source =
          config.lib.file.mkOutOfStoreSymlink configFile;
        ".var/app/com.usebottles.bottles/config/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json".source =
          layerJson;
        ".var/app/com.usebottles.bottles/config/lsfg-vk/conf.toml".source =
          config.lib.file.mkOutOfStoreSymlink configFile;
      };
    };
}
