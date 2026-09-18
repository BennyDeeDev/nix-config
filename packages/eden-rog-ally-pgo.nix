{ appimageTools, fetchurl }:

let
  version = "0.2.1";
in
appimageTools.wrapType2 {
  pname = "eden-rog-ally-pgo";
  inherit version;

  src = fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/releases/download/v${version}/Eden-Linux-v${version}-rog-ally-clang-pgo.AppImage";
    hash = "sha256-Ak3+MH9+W1ObNUm9kkX2txybqpzHRPMdWNMYGFfYX/w=";
  };
}
