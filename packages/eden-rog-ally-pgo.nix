{
  appimageTools,
  dwarfs,
  fetchurl,
  runCommand,
}:

let
  version = "0.2.1";
in
appimageTools.wrapAppImage (finalAttrs: {
  pname = "eden-rog-ally-pgo";
  inherit version;

  src = fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v${version}/Eden-Linux-v${version}-rog-ally-clang-pgo.AppImage";
    hash = "sha256-Ak3+MH9+W1ObNUm9kkX2txybqpzHRPMdWNMYGFfYX/w=";
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

  meta.mainProgram = finalAttrs.pname;
})
