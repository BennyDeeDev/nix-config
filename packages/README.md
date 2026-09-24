# Packages

Each `.nix` file in this directory is exposed as a package with the same name
without the `.nix` suffix.

Package expressions should stay minimal:

```nix
{ appimageTools, fetchurl }:

appimageTools.wrapType2 {
  pname = "package-name";
  version = "1.0.0";
  src = fetchurl {
    url = "https://example.org/package-${version}.AppImage";
    hash = "sha256-...";
  };
}
```

## Initial Hash

Use a temporary fake hash:

```nix
hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
```

Then update only the source hash:

```sh
nix run github:Mic92/nix-update -- \
  --flake \
  --version=skip \
  package-name
```

Build the package and commit the real hash:

```sh
nix build .#package-name
```

## Updates

Update every package:

```sh
./packages/update.sh
```

Update one package:

```sh
nix run github:Mic92/nix-update -- \
  --flake \
  package-name
```

## AppImage Payloads

`appimageTools.wrapType2` extracts Type 2 AppImages with `unsquashfs`.
Some AppImages use DwarFS instead, so `wrapType2` cannot extract them.

There are two approaches:

- Keep the verified AppImage intact in `$out/bin`. This is simplest and preserves the vendor runtime.
- Extract with `dwarfsextract`, then use `appimageTools.wrapAppImage`. This gives Nix more control but creates many files and consumes more inodes.
