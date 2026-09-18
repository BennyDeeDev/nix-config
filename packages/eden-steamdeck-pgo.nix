{ appimageTools, fetchurl }:

let
  version = "0.2.1";
in
appimageTools.wrapType2 {
  pname = "eden-steamdeck-pgo";
  inherit version;

  src = fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v${version}/Eden-Linux-v${version}-steamdeck-clang-pgo.AppImage";
    hash = "sha256-XMWzWKxkSbQAIbILokMLTRIwJzfbFcjL5bRs6aq4XOU=";
  };
}
