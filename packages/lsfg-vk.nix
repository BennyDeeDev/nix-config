{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk";
  version = "2.0.0";

  src = fetchurl {
    url = "https://builds.lsfg-vk.dev/lsfg-vk-${finalAttrs.version}.tar.xz";
    hash = "sha256-CL2983OhEQIt+H2seqh+O1ZLuEH5YVUuPKhf6hK1qnQ=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 lib/liblsfg-vk-layer.so \
      "$out/lib/liblsfg-vk-layer.so"
    install -Dm644 \
      share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json \
      "$out/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json"

    runHook postInstall
  '';

  meta = {
    description = "Vulkan frame generation layer using Lossless Scaling";
    homepage = "https://lsfg-vk.dev";
    license = lib.licenses.cc-by-nc-nd-40;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
