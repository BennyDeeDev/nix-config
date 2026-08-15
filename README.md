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

The repository uses explicit, scope-first feature facets.

```text
files/       Application payloads
hosts/       Machine identity, hardware, disks, and unique policy
images/      Image outputs
modules/     Reusable modules selected explicitly
profiles/    Explicit system, terminal, and graphical contexts
secrets/     Encrypted SOPS documents
```

Profile composition is explicit. Terminal and graphical entry points list
their features, while the system entry point combines platform foundations
and `flake.nix` selects host capabilities:

```text
profiles/system/default.nix
profiles/terminal/default.nix
profiles/graphical/default.nix
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
macOS use `pkgs.stdenv.isLinux` or `pkgs.stdenv.isDarwin` where needed. The
flake composes profile facets, reusable modules, and host modules directly;
only the mutable checkout path is passed to Home Manager through
`extraSpecialArgs`.

## Ownership

`profiles/system/` contains the operating-system foundation and explicitly
selected capabilities such as boot, audio, networking, printing, containers,
and virtualization.

`profiles/terminal/` contains the shell, command-line tools, and terminal
editors. `profiles/graphical/` contains the Niri desktop, GUI applications,
fonts, and desktop integration.

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

A terminal Home Manager feature uses the same facet shape:

```nix
# profiles/terminal/example.nix
{ ... }:

{
  homeManager = {
    programs.example.enable = true;
  };
}
```

Add the facet explicitly to `profiles/terminal/default.nix`. System
capabilities and machine-specific behavior remain explicit in `flake.nix` or
the relevant host.

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
nix eval --raw .#nixosConfigurations.vm.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.pi5-server.config.system.build.toplevel.drvPath
nix eval --raw .#images.pi5-bootstrap.drvPath
```

Build an output with `nix build --no-link <installable>`.

## Installation

- [Desktop installation and Secure Boot](hosts/desktop/README.md)
- [MacBook bootstrap](hosts/mbp-personal/README.md)
- [Raspberry Pi deployment](hosts/pi5-server/README.md)
- [Secret management](secrets/README.md)
