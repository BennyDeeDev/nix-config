# Dotfiles

NixOS, nix-darwin, and Home Manager configuration for the machines below.

| Output | Role |
| --- | --- |
| `desktop` | NixOS workstation and gaming host |
| `mbp-personal` | Personal macOS workstation |
| `pi5-server` | Home automation server |
| `pi5-kiosk` | Planned kiosk |
| `images.pi5-bootstrap` | Raspberry Pi 5 bootstrap image |
| `vm` | Development VM |

## Architecture

The repository uses scope-first, auto-composed feature facets.

```text
files/       Application payloads
hosts/       Machine identity, hardware, disks, and unique policy
images/      Image outputs
lib/         Composition helpers
modules/     Reusable modules selected explicitly
profiles/    Automatically composed system and workstation contexts
secrets/     Encrypted SOPS documents
```

An auto-composed context is a directory whose `default.nix` is its public
entry point and whose sibling Nix files are enabled automatically:

```text
profiles/system/default.nix
profiles/workstation/default.nix
hosts/desktop/gaming/default.nix
```

Feature files return the module-system facets they support:

```nix
{
  nixos = { ... };
  homeManager = { ... };
  darwin = { ... };
}
```

Unsupported facets are omitted. Home Manager facets shared between Linux and
macOS use `pkgs.stdenv.isLinux` or `pkgs.stdenv.isDarwin` where needed.

`lib/load-features.nix` loads sibling files in sorted order and combines each
facet through normal module imports. `modules/default.nix` is deliberately an
explicit registry: adding a reusable module does not enable it automatically.

## Ownership

`profiles/system/` contains the operating-system foundation. `nixos.nix`
owns shared NixOS policy and `macos.nix` owns shared nix-darwin and macOS Home
Manager policy.

`profiles/workstation/` contains features present on every daily-use machine.
A future Linux laptop can reuse the same NixOS and Home Manager facets as the
desktop without importing desktop hardware or gaming.

`hosts/<name>/` contains machine facts: hostnames, hardware, disks, users,
state versions, secret files, and unique mounts or applications.

`hosts/desktop/gaming/` is intentionally private to the physical desktop.

## Feature Granularity

A configured feature owns a dedicated file. Features may be combined only
when they are trivial package installations or simple upstream module enables
within one clear usage domain.

Dedicated files are appropriate when a feature owns settings, payloads,
plugins, services, timers, permissions, firewall policy, coordinated
dependencies, activation behavior, or an independent lifecycle. For example,
`nautilus.nix` owns Nautilus together with GVFS, GNOME Disks, thumbnailing,
and directory MIME handling.

Simple GUI applications live in `apps.nix`. Simple command-line programs and
shell integrations live in `cli.nix`. Helix has its own file because its
editor configuration is expected to grow.

Prefer upstream `programs.*`, `services.*`, and `virtualisation.*` modules
when they represent the intended behavior. When a direct package is retained
despite a related module, leave a short comment explaining the decision.

## Adding A Feature

A workstation-only Home Manager program needs only a sibling file:

```nix
# profiles/workstation/example.nix
{ ... }:

{
  homeManager = {
    programs.example.enable = true;
  };
}
```

Adding the file enables it on every applicable workstation. Put optional or
machine-specific behavior in an explicit module or host instead.

## Validation

Format the Nix tree and verify that formatting is clean:

```sh
nix fmt
nix fmt -- --ci
```

Evaluate the active outputs without activating them:

```sh
nix eval --raw .#darwinConfigurations.mbp-personal.system.drvPath
nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.pi5-server.config.system.build.toplevel.drvPath
nix eval --raw .#images.pi5-bootstrap.drvPath
```

Build an output with `nix build --no-link <installable>`.

## Installation

- [Desktop installation and Secure Boot](hosts/desktop/README.md)
- [MacBook bootstrap](hosts/mbp-personal/README.md)
- [Raspberry Pi deployment](hosts/pi5-server/README.md)
- [Secret management](secrets/README.md)
