# Nix Config

Personal NixOS, nix-darwin, and Home Manager configurations, with reusable
profiles for other flakes.

## Repository layout

```text
hosts/       Machine identity, hardware, disks, users, and host-specific settings
images/      Bootable image configurations
modules/     Reusable modules selected by hosts and profiles
packages/    Package definitions and update script
profiles/    Reusable configuration bundles
secrets/     SOPS-encrypted YAML documents
```

Hosts select profiles and reusable modules, then add machine-specific settings.
Shared modules are platform-neutral; NixOS and Darwin policy belongs in the
respective profiles. `profiles/default.nix` lists the exported profiles.

## Profiles

The flake exports these bundles through `profiles`. Each supported module
system has its own facet: `nixos`, `homeManager`, or `darwin`.

| Profile | Facets | Purpose |
| --- | --- | --- |
| [`apps`](profiles/apps/) | `homeManager` | Desktop applications, Ghostty, VS Code, and application keybindings |
| [`gaming`](profiles/gaming/) | `nixos`, `homeManager` | Steam, Flatpak applications, Bottles, LSFG, and save backups |
| [`nixos`](profiles/nixos/) | `nixos` | Base NixOS settings and secret management |
| [`nixosDesktop`](profiles/nixos-desktop/) | `nixos`, `homeManager` | Workstation services, boot, hardware integration, and virtualisation |
| [`kde`](profiles/kde/) | `nixos`, `homeManager` | Plasma desktop, panels, shortcuts, and tiling |
| [`macos`](profiles/macos/) | `homeManager`, `darwin` | macOS settings, applications, and Hammerspoon |
| [`pi5`](profiles/pi5/) | `nixos` | Raspberry Pi users, SSH, and filesystems |
| [`terminal`](profiles/terminal/) | `homeManager` | Shell, CLI tools, editors, Git, and SSH |

Select each profile and facet explicitly. For example, a NixOS workstation
can combine `nixos`, `nixosDesktop`, `apps`, `kde`, and `terminal`.

## Hosts and images

| Output | Role | Setup |
| --- | --- | --- |
| `nixosConfigurations.desktop` | Workstation and gaming host | [Installation and Secure Boot](hosts/desktop/README.md) |
| `darwinConfigurations.mbp-personal` | Personal macOS workstation | [Bootstrap](hosts/mbp-personal/README.md) |
| `nixosConfigurations.pi5-server` | Homelab server | [Deployment](hosts/pi5-server/README.md) |
| `nixosConfigurations.pi5-kiosk` | Planned kiosk | — |
| `homeConfigurations.deck` | SteamOS Home Manager configuration | [Bootstrap and SteamOS notes](hosts/deck/README.md) |
| `images.pi5-bootstrap` | Raspberry Pi 5 bootstrap SD image | [Build and flash](hosts/pi5-server/README.md#1-build-the-bootstrap-sd-image) |

## Documentation

- [Desktop installation and Secure Boot](hosts/desktop/README.md)
- [MacBook bootstrap](hosts/mbp-personal/README.md)
- [Raspberry Pi deployment and Home Assistant](hosts/pi5-server/README.md)
- [Steam Deck bootstrap and SteamOS notes](hosts/deck/README.md)
- [Gaming setup and troubleshooting](profiles/gaming/README.md)
- [Package definitions and updates](packages/README.md)
- [Secret management](secrets/README.md)

## Use from another flake

Add this repository as an input and import the facets into their matching
module systems. This example adds base NixOS settings, desktop applications,
and terminal tools to an existing host:

```nix
{
  inputs = {
    nixConfig.url = "github:BennyDeeDev/nix-config";
    nixpkgs.follows = "nixConfig/nixpkgs";
    home-manager.follows = "nixConfig/home-manager";
  };

  outputs = { nixpkgs, home-manager, nixConfig, ... }:
    let
      profiles = nixConfig.profiles;
    in
    {
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          profiles.nixos.nixos
          home-manager.nixosModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = {
                nixConfig = "/home/benjamin/Repos/my-config";
                flakeHost = "example";
              };
              users.benjamin = {
                imports = [
                  profiles.apps.homeManager
                  profiles.terminal.homeManager
                ];
                home.stateVersion = "26.05";
              };
            };
          }
        ];
      };
    };
}
```

## Making changes

### Adding a feature

1. Put the feature in the relevant profile, or in the host if it is
   machine-specific. Use `modules/` for reusable modules shared across profiles
   or hosts.
2. Declare its supported facets. For example:

   ```nix
   # profiles/terminal/example.nix
   {
     homeManager = {
       programs.example.enable = true;
     };
   }
   ```

3. Bind the import in the profile's `default.nix` and add its facet to the
   existing imports:

   ```nix
   let
     example = import ./example.nix;
   in
   {
     homeManager.imports = [ example.homeManager ];
   }
   ```

4. Format the files and evaluate the affected outputs as described under
   [Validation](#validation).

### Module structure

- Hand-written modules in `profiles/`, `hosts/`, `images/`, and `modules/`
  expose only the facets they implement, ordered `nixos`, `homeManager`, then
  `darwin`. Home Manager facets may serve integrated or standalone setups.
- `default.nix` files compose facets through `imports`; feature settings belong
  in feature files.
- Keep configured features in dedicated files when they own settings, payloads,
  plugins, services, timers, permissions, firewall rules, dependencies,
  activation behavior, or an independent lifecycle. Trivial package installs
  and simple upstream enables may share a file within one usage domain.
- Every profile has a `profile.nix` for small miscellaneous settings; hosts use
  `host.nix`. A one-line setting may go there. Keep multiple related settings
  together in a feature file, and avoid using these buckets to hide named
  feature configuration.
- Prefer upstream `programs.*`, `services.*`, and `virtualisation.*` modules.
  If a direct package is a better fit, briefly explain why in a comment.
- Structural exceptions to the facet rule are `flake.nix`,
  `profiles/default.nix`, `hosts/desktop/disko.nix`, and the generated
  `hosts/desktop/hardware-configuration.nix`.

### Nix style

#### Names and bindings

- Bind every `import` in the nearest enclosing `let` before using it.
- Use the `Module` suffix for imports from `modules/`, such as `nasModule`.
  Use the feature name for profile imports, such as `helix`.
- Use `homeManagerModule` for the module registering Home Manager with NixOS or
  nix-darwin, and `homeManagerConfig` for host-specific `home-manager.users`
  configuration.
- Declare repository-owned options under `my.*`, such as `my.sops` or
  `my.restic`.
- Define related aliases together and in the same style, even if an individual
  alias is used only once.
- Otherwise, introduce a binding only when its name adds meaning and the value
  is reused. Keep simple configuration data inline; bind a repeated fragment
  only when the name expresses a useful concept.

#### Attribute sets and collections

Group a dotted path when it has multiple child keys; keep singleton paths
dotted:

```nix
programs.vim = {
  enable = true;
  defaultEditor = true;
};
programs.helix.enable = true;
```

Keep small, explicit collections readable rather than generating them to remove
repetition. For transformations, bind the mapping function in `let` and use:

| Transformation | Function |
| --- | --- |
| List to list | `map` |
| Attribute set, preserving keys | `lib.mapAttrs` |
| Attribute set, changing keys | `lib.mapAttrs'` |
| Attribute set to list | `lib.mapAttrsToList` |
| Names to attributes with the same keys | `lib.genAttrs` |
| Names to attributes with different keys | `lib.genAttrs'` |
| Explicit name-value pairs | `lib.listToAttrs` with `lib.nameValuePair` |

#### Configuration and paths

- Use the application's native configuration format for substantial
  configuration, such as Lua for Neovim.
- Check platforms with `pkgs.stdenv.hostPlatform.isLinux`; treat the `else`
  branch as Darwin rather than checking `isDarwin` separately.
- For runtime-editable files, prefer `config.lib.file.mkOutOfStoreSymlink`
  pointing into the mutable checkout, especially for live theme changes.
- In Nix-generated files, use `lib.getExe` for a package's main program and
  `lib.getExe'` for a specific executable. Prefer configured package options
  where available. Use stable profile paths for mutable external configuration
  that may outlive a Nix store reference.

### Documentation style

- In runnable guides, use `nix run` for tools the reader may not have installed.
- For development and validation, use installed tools directly; fall back to
  Nix when needed.
- Keep tool names short in prose.
- Keep commands on one line when they fit comfortably. Use backslash
  continuations for long commands or commands with many options. When splitting,
  keep subcommands and option/value pairs together.
- Keep shell builtins, native OS commands, and Nix commands in their normal
  form. Select the correct executable when a package contains multiple binaries.
- Check all Markdown changes with `rumdl`.

## Validation

Format Nix files with `nixfmt`.

Evaluate the active outputs without activating them:

```bash
nix eval --raw .#darwinConfigurations.mbp-personal.system.drvPath
nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.pi5-server.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.pi5-kiosk.config.system.build.toplevel.drvPath
nix eval --raw .#homeConfigurations.deck.activationPackage.drvPath
nix eval --raw .#images.pi5-bootstrap.drvPath
```

Build an output with `nix build --no-link <installable>`.

### Compare configurations

`nix-diff` compares derivations without building either system, including when
the target architecture differs from the machine running the comparison.

Fetch the comparison branch:

```bash
git fetch origin master
```

Compare a NixOS host with `origin/master`:

```bash
host=desktop

master_drv=$(nix eval --raw \
  "git+file://$PWD?ref=refs/remotes/origin/master#nixosConfigurations.$host.config.system.build.toplevel.drvPath")
current_drv=$(nix eval --raw \
  ".#nixosConfigurations.$host.config.system.build.toplevel.drvPath")

nix run nixpkgs#nix-diff -- \
  "$master_drv" "$current_drv" \
  --skip-already-compared --color auto --context 1
```

Use `host=pi5-server` or `host=pi5-kiosk` for the Pi configurations. For
nix-darwin, compare the `system` output:

```bash
host=mbp-personal

master_drv=$(nix eval --raw \
  "git+file://$PWD?ref=refs/remotes/origin/master#darwinConfigurations.$host.system.drvPath")
current_drv=$(nix eval --raw \
  ".#darwinConfigurations.$host.system.drvPath")

nix run nixpkgs#nix-diff -- \
  "$master_drv" "$current_drv" \
  --skip-already-compared --color auto --context 1
```

Use `nix store diff-closures` to compare realized outputs after both have been
built. It compares the resulting closures rather than the build recipes.
