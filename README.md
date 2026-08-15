# Dotfiles

NixOS, nix-darwin, and Home Manager configuration for the machines below.

| Output | Role |
| --- | --- |
| `desktop` | NixOS workstation and gaming host |
| `mbp-personal` | Personal macOS workstation |
| `pi5-server` | Home automation server |
| `pi5-kiosk` | Planned kiosk |
| `images.pi5-bootstrap` | Raspberry Pi 5 bootstrap image |

## Architecture

The repository uses explicit, scope-first feature facets.

```text
files/       Application payloads
hosts/       Machine identity, hardware, disks, and unique policy
images/      Image outputs
modules/     Reusable modules selected explicitly
profiles/    Explicit base, system, terminal, and graphical bundles
secrets/     Encrypted SOPS documents
```

Profile composition is explicit. `base` provides the universal foundation;
`system`, `terminal`, `graphical`, and `pi5` are complete opinionated bundles.
`profiles/default.nix` is their explicit catalog; each host selects whole
profiles and reusable host modules:

```text
profiles/base/default.nix
profiles/system/default.nix
profiles/terminal/default.nix
profiles/graphical/default.nix
profiles/pi5/default.nix
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
macOS use `pkgs.stdenv.isLinux` or `pkgs.stdenv.isDarwin` where needed. Host
modules compose profile facets and reusable modules directly. `flake.nix`
only instantiates outputs and provides their external flake dependencies;
only the mutable checkout path is passed to Home Manager through
`extraSpecialArgs`.

## Ownership

`profiles/base/` contains the NixOS and nix-darwin foundation shared by
workstations, servers, and images.

`profiles/system/` is the complete daily-machine system policy. Its NixOS
facet requires Btrfs and UEFI Secure Boot and enables audio, Bluetooth,
networking, printing, containers, and virtualization. Its Darwin facet owns
the corresponding opinionated macOS system policy.

`profiles/terminal/` contains the shell, command-line tools, and terminal
editors. `profiles/graphical/` contains the Niri desktop, GUI applications,
fonts, and desktop integration. `profiles/pi5/` contains the shared Pi user,
SSH, filesystem, and lifecycle policy.

`hosts/<name>/` selects whole profiles and contains machine facts: hostnames,
hardware, disks, users, state versions, secret files, and unique mounts or
applications.

`hosts/desktop/gaming/` is intentionally private to the physical desktop.
`hosts/vm/` is retained but has no flake output until the ext4 VM is rebuilt
with the Btrfs system-profile contract.

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

Application payloads intentionally use mixed update semantics. DMS, Neovim,
VS Code, and gaming files link to the mutable checkout for rapid iteration;
Niri, Ghostty, OpenCode, and other system-owned files are store-backed and
require a rebuild. Workstation hosts therefore require the repository at
`~/Repos/dotfiles`.

Prefer upstream `programs.*`, `services.*`, and `virtualisation.*` modules
when they represent the intended behavior. When a direct package is retained
despite a related module, leave a short comment explaining the decision.

## Adding A Feature

A terminal Home Manager feature uses the same facet shape:

```nix
# profiles/terminal/example.nix
{
  homeManager = {
    programs.example.enable = true;
  };
}
```

Add the facet explicitly to `profiles/terminal/default.nix`. Machine-specific
behavior remains explicit in the relevant host.

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
nix eval --raw .#nixosConfigurations.pi5-kiosk.config.system.build.toplevel.drvPath
nix eval --raw .#images.pi5-bootstrap.drvPath
```

Build an output with `nix build --no-link <installable>`.

## Installation

- [Desktop installation and Secure Boot](hosts/desktop/README.md)
- [MacBook bootstrap](hosts/mbp-personal/README.md)
- [Raspberry Pi deployment](hosts/pi5-server/README.md)
- [Secret management](secrets/README.md)
