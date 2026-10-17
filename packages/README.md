# Packages

Package definitions live here; [`flake.nix`](../flake.nix) explicitly exports
them under `packages.x86_64-linux`. Adding a file alone does not export it.
Run the commands below from the checkout root on an `x86_64-linux` machine.

## Add a package

### 1. Write the definition

Create `packages/package-name.nix`. For a Type 2 AppImage using SquashFS:

```nix
{ appimageTools, fetchurl, lib }:

let
  version = "1.0.0";
in
appimageTools.wrapType2 {
  pname = "package-name";
  inherit version;
  src = fetchurl {
    url = "https://example.org/package-${version}.AppImage";
    hash = lib.fakeHash;
  };
}
```

### 2. Export it from the flake

Add the package alongside the existing definitions in `flake.nix`:

```nix
packages.x86_64-linux.package-name =
  pkgsX86Linux.callPackage ./packages/package-name.nix { };
```

The update script expects each package export to match its filename without
the `.nix` suffix. Track the new file so the Git-backed flake includes it:

```bash
git add packages/package-name.nix
```

### 3. Obtain the source hash

Replace the temporary hash without changing the version:

```bash
nix run github:Mic92/nix-update -- --flake --version=skip package-name
```

Build the package and commit the definition and export after reviewing them:

```bash
nix build --no-link .#package-name
```

## Update packages

Update every exported package corresponding to `packages/*.nix`:

```bash
./packages/update.sh
```

The script accepts release tags matching `vMAJOR.MINOR.PATCH`. To update a
single package with the same tag filter:

```bash
nix run github:Mic92/nix-update -- \
  --flake \
  --version-regex '^v([0-9]+\.[0-9]+\.[0-9]+)$' \
  package-name
```

For a package with a different release scheme, adjust the filter or omit it.
Review the changed version, URL, and hash, then build the affected packages.

## AppImage formats

`appimageTools.wrapType2` extracts SquashFS-based Type 2 AppImages. It cannot
extract DwarFS payloads. The Eden definitions use `dwarfsextract` followed by
`appimageTools.wrapAppImage`; see
[`eden-steamdeck-pgo.nix`](eden-steamdeck-pgo.nix) for the extraction and
desktop integration.

Keeping an AppImage intact preserves its vendor runtime, but that runtime must
work on the target host. Extracting and wrapping it gives Nix control over
the runtime environment, at the cost of additional files and inodes.
