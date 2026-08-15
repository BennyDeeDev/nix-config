This Nix config is a black hole for wasted time, water, and money: personal costs are probably over 500 EUR because I am a lazy fuck and couldn't be bothered, while the unsubsidized AI bill is over 9000 (Vegeta meme goes here); the machinery's water use has real environmental costs, multiple people in Africa died of thirst because AI used all the water for this, and it just keeps going. The robot tells me it doesn't want to stop.

The Dendritic pattern is already an overengineered piece of software for people who don't know how to import things, but apparently it was not extravagant enough for me. I looked at it and thought, "I can waste even more time than this," so I created my own version.

My wife keeps wondering where all the money goes and why I am not walking the dog, because I am eternally tied to maintaining this Nix config: it has to be "pure". Have you heard of Nix Impermanence? It is even more pure, so pure it is like Dana White's bald head.

Right as I am writing this, I am dropping into the next Nix rabbit hole. It is in my blood to fight the everlasting impurity of applications, so we write yet another wrapper in Nix.

## Boring Documentation for Lunatics and Robots

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

## Feature Granularity

A configured feature owns a dedicated file. Features may be combined only
when they are trivial package installations or simple upstream module enables
within one clear usage domain.

Dedicated files are appropriate when a feature owns settings, payloads,
plugins, services, timers, permissions, firewall policy, coordinated
dependencies, activation behavior, or an independent lifecycle.

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

### Attrset Style

Collapse a dotted path only when that path has multiple child keys in the same
attrset. For example:

```nix
programs.vim.enable = true;
programs.vim.defaultEditor = true;
```

becomes:

```nix
programs.vim = {
  enable = true;
  defaultEditor = true;
};
```

Keep singleton paths dotted:

```nix
programs.helix.enable = true;
```

### Let Bindings

Use a `let` binding only when the bound value is used more than once. Keep
one-off expressions inline instead of introducing a local name.

### Custom Module Options

Options declared by modules in this repository use the `my.*` namespace to
separate them from built-in NixOS, nix-darwin, Home Manager, and upstream
module options. Current examples include `my.sops`, `my.nas`, and
`my.containerBackups`.

### Configuration Style

Prefer the application's native configuration format when configuration is
substantial or likely to grow. For example, use a real Lua file for Neovim
instead of encoding the configuration through Nix attrset hacks.

Prefer `config.lib.file.mkOutOfStoreSymlink` for configuration files that need
to remain editable at runtime, especially when theme switches or other live
changes are expected. Link those files from the mutable dotfiles checkout
instead of copying them into the Nix store.

### File Size

Keep files glanceable. Around 100 lines is a useful signal to reconsider the
structure and split a file into sensible, cohesive files, but it is not a
hard limit. Do not fragment tightly coupled configuration merely to reduce
the line count.

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

### Compare Hosts Without Building

Nix can evaluate a system to its `.drv` path without realizing the system
closure. A derivation is the build recipe: it records the builder, inputs, and
environment, so `nix-diff` can compare two configurations before either one is
built.

Fetch the branch you want to compare first:

```sh
git fetch origin master
```

Then compare the current checkout with `origin/master`. For NixOS hosts:

```sh
host=desktop

master_drv=$(nix eval --raw \
  "git+file://$PWD?ref=refs/remotes/origin/master#nixosConfigurations.$host.config.system.build.toplevel.drvPath")
current_drv=$(nix eval --raw \
  ".#nixosConfigurations.$host.config.system.build.toplevel.drvPath")

nix run nixpkgs#nix-diff -- \
  "$master_drv" "$current_drv" \
  --skip-already-compared --color auto --context 1
```

Use `host=pi5-server` for the Pi. For nix-darwin, use its `system` output:

```sh
host=mbp-personal

master_drv=$(nix eval --raw \
  "git+file://$PWD?ref=refs/remotes/origin/master#darwinConfigurations.$host.system.drvPath")
current_drv=$(nix eval --raw \
  ".#darwinConfigurations.$host.system.drvPath")

nix run nixpkgs#nix-diff -- \
  "$master_drv" "$current_drv" \
  --skip-already-compared --color auto --context 1
```

This compares the dependency graph and generated configuration, not the final
store closures. It works from a different architecture because evaluation is
not execution: an `aarch64-darwin` machine can inspect an `x86_64-linux` or
`aarch64-linux` derivation, but it cannot build that closure without a suitable
builder. Use `nix store diff-closures` only after both system outputs have been
realized; it compares resulting closures and therefore does require builds.

## Installation

- [Desktop installation and Secure Boot](hosts/desktop/README.md)
- [MacBook bootstrap](hosts/mbp-personal/README.md)
- [Raspberry Pi deployment](hosts/pi5-server/README.md)
- [Secret management](secrets/README.md)
