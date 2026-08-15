{ ... }:

{
  homeManager =
    {
      config,
      dotfiles,
      pkgs,
      ...
    }:
    let
      layerJson = "${pkgs.lsfg-vk}/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json";
      configFile = "${dotfiles}/files/gaming/lsfg-vk/conf.toml";
    in
    {
      home.packages = [ pkgs.lsfg-vk ];

      home.file.".config/lsfg-vk/conf.toml".source = config.lib.file.mkOutOfStoreSymlink configFile;

      services.flatpak.overrides."io.github.ryubing.Ryujinx".Context.filesystems = [
        "${dotfiles}/files/gaming/lsfg-vk:ro"
      ];
      home.file.".var/app/io.github.ryubing.Ryujinx/config/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json".source =
        layerJson;
      home.file.".var/app/io.github.ryubing.Ryujinx/config/lsfg-vk/conf.toml".source =
        config.lib.file.mkOutOfStoreSymlink configFile;

      services.flatpak.overrides."com.usebottles.bottles".Context.filesystems = [
        "${dotfiles}/files/gaming/lsfg-vk:ro"
      ];
      home.file.".var/app/com.usebottles.bottles/config/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json".source =
        layerJson;
      home.file.".var/app/com.usebottles.bottles/config/lsfg-vk/conf.toml".source =
        config.lib.file.mkOutOfStoreSymlink configFile;
    };
}
