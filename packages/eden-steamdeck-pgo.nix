{
  appimageTools,
  dwarfs,
  fetchurl,
  lib,
  runCommand,
}:

let
  version = "0.2.1";
in
appimageTools.wrapAppImage (finalAttrs: {
  pname = "eden-steamdeck-pgo";
  inherit version;

  src = fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v${version}/Eden-Linux-v${version}-steamdeck-clang-pgo.AppImage";
    hash = "sha256-XMWzWKxkSbQAIbILokMLTRIwJzfbFcjL5bRs6aq4XOU=";
  };

  contents =
    runCommand "${finalAttrs.pname}-${finalAttrs.version}-contents"
      {
        nativeBuildInputs = [ dwarfs ];
        strictDeps = true;
      }
      ''
        mkdir -p "$out"
        dwarfsextract \
          --input "${finalAttrs.src}" \
          --output "$out"
      '';

  extraInstallCommands = ''
    install -Dm444 \
      "${finalAttrs.contents}/dev.eden_emu.eden.desktop" \
      "$out/share/applications/dev.eden_emu.eden.desktop"
    install -Dm444 \
      "${finalAttrs.contents}/dev.eden_emu.eden.svg" \
      "$out/share/icons/hicolor/scalable/apps/dev.eden_emu.eden.svg"

    substituteInPlace "$out/share/applications/dev.eden_emu.eden.desktop" \
      --replace-fail 'TryExec=eden' "" \
      --replace-fail 'Exec=eden %f' 'Exec=${finalAttrs.pname} %f'
  '';

  meta = {
    description = "Nintendo Switch emulator";
    homepage = "https://eden-emu.dev";
    license = lib.licenses.gpl3Plus;
    mainProgram = finalAttrs.pname;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
