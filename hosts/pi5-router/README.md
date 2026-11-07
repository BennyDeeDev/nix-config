# Pi 5 router bring-up

Minimal IPv4 router using the ZDE ZP595 dual RTL8125 HAT. This is a separate
host from `pi5-server`; it does not run the server's application stack.

## Wiring and addresses

| Pi interface | Role | Address | DHCP pool |
| --- | --- | --- | --- |
| `end0` | Upstream to Fritz!Box LAN; SSH management | DHCP from Fritz!Box | None served |
| `enP1p3s0` | DMZ test network | `10.77.20.1/24` | `10.77.20.100–199` |
| `enP1p4s0` | Trusted test network | `10.77.10.1/24` | `10.77.10.100–199` |

The HAT ports are separate routed interfaces, not a bridge. Their PCI paths
identify them; locally administered MAC addresses replace the random addresses
reported by the hardware. The stable MAC settings take effect when the devices
are next initialized, normally after reboot. Map the physical sockets by
connecting one cable at a time and checking `ip -br link`.

dnsmasq serves DHCP, DNS and DHCP lease names under `home.arpa` only on the
two downstream interfaces. It forwards external DNS queries to the Fritz!Box
at `192.168.178.1`. The router uses networkd/resolved for its own DNS.

Outbound IPv4 traffic is masqueraded through `end0`. No Fritz!Box static routes
are needed; while the Fritz!Box remains upstream, internet access uses double
NAT. IPv6 routing and public port forwarding are not configured.

**This is a lab configuration, not an isolated DMZ.** Routing between the two
downstream networks is deliberately allowed in both directions for testing.
Both can also reach the upstream Fritz!Box network. The NixOS firewall is
disabled: there are no input or forwarding filters, and SSH is reachable
through all interfaces. nftables is used only for outbound NAT. Keep this
behind the Fritz!Box without public port forwards. Add a firewall and zone
isolation before connecting untrusted services or exposing anything publicly.

## Prerequisite: enroll the router key

Boot the
[generic bootstrap image](../pi5-server/README.md#bootstrap-and-deploy).
Keep `end0` connected to the Fritz!Box and verify SSH to
`benjamin@pi.fritz.box`.

The supplied router public key is registered as `pi5-router` in `.sops.yaml`.
Before deployment, verify that it matches this Pi's current age key. On the Pi:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#age --command age-keygen -y /var/lib/sops-nix/key.txt
```

Only `secrets/shared.yaml` is needed, for the password configured by the Pi
profile. Apply the recipient change using an enrolled YubiKey on the PC:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"
nix run nixpkgs#sops -- updatekeys secrets/shared.yaml
```

Do not deploy until rekeying succeeds. Changing `.sops.yaml` alone does not
grant the Pi access to the encrypted file. Keep the rule and encrypted metadata
changes together; do not copy or print the private age key.

## Validate and deploy

Run from the repository root. Ensure the new host files are tracked by Git
before using the Git-backed flake.

```bash
nix eval --raw .#nixosConfigurations.pi5-router.config.system.build.toplevel.drvPath
nix build --no-link .#nixosConfigurations.pi5-router.config.system.build.toplevel
```

The PC needs AArch64 emulation or a suitable builder for the build.
Alternatively, the rebuild commands below build on the Pi itself.

### Build before arming rollback

Changing from dhcpcd to networkd may briefly interrupt SSH and change the DHCP
lease. Reserve the Pi's built-in Ethernet MAC (`2c:cf:67:1c:66:fa`) in the
Fritz!Box if a fixed management IP is required. The bootstrap address observed
during bring-up was `192.168.178.54`; verify it before using the commands below.

Build on the Pi first so downloading and building do not use the rollback
window:

```bash
nixos-rebuild build --flake .#pi5-router \
  --build-host benjamin@192.168.178.54
```

### Test activation with rollback

First, in an SSH session on the Pi, schedule rollback to its current system:

```bash
old_system=$(readlink -f /run/current-system)
sudo systemd-run --unit=router-rollback --on-active=10m \
  "$old_system/bin/switch-to-configuration" test
```

Then, from the PC, test the new configuration without changing the boot default:

```bash
nixos-rebuild test --flake .#pi5-router \
  --target-host benjamin@192.168.178.54 \
  --build-host benjamin@192.168.178.54 \
  --sudo
```

Reconnect using the lease shown in the Fritz!Box or `pi5-router.fritz.box`.
The deployed profile requires the user's password for sudo. On the Pi, check:

```bash
ip -br address
ip -4 route
networkctl status end0 enP1p3s0 enP1p4s0
systemctl --failed
systemctl status dnsmasq
journalctl -u dnsmasq -b --no-pager
sudo nft list ruleset
```

Verify SSH and router DNS/internet access. Once satisfied, cancel the timer
on the Pi before it expires:

```bash
sudo systemctl stop router-rollback.timer
```

If management access fails, wait for rollback, then reconnect to the old
hostname/address. A reboot also restores the previous boot configuration after
a test activation. With working management confirmed, make it persistent from
the PC:

```bash
nixos-rebuild switch --flake .#pi5-router \
  --target-host benjamin@pi5-router.fritz.box \
  --build-host benjamin@pi5-router.fritz.box \
  --sudo --ask-sudo-password
```

Schedule a fresh rollback timer for later network changes too. Recheck SSH
and both downstream networks after the first reboot.

## PC namespace tests

Keep the PC's normal Ethernet interface (`enp14s0`) and Wi-Fi in its original
namespace. Move only the two dedicated USB Ethernet adapters into separate
test namespaces. Their interface names depend on the USB ports; identify them
by MAC address before moving anything:

| Adapter MAC | Name observed on USB 3 |
| --- | --- |
| `9c:69:d3:b2:d2:35` | `enp19s0f3u2c2` |
| `9c:69:d3:b3:05:9b` | `enp19s0f4u1c2` |

Give each namespace its own DHCP client and resolver settings; do not let a
client overwrite the host's `/etc/resolv.conf`. Connect one adapter to each
Pi downstream port. No PC network changes are made by this NixOS host.

Validate in order:

1. One DHCP lease in each corresponding subnet, with its Pi gateway as DNS.
2. Ping the namespace's own Pi gateway.
3. DNS resolution and outbound IPv4 internet access from each namespace.
4. Bidirectional traffic between namespace clients, routed through the Pi.
5. Throughput between namespaces using iperf3, then upstream throughput.

For example, after namespace setup, run a server in the DMZ client:

```bash
sudo ip netns exec router-dmz nix run nixpkgs#iperf3 -- -s -4
```

In another terminal, substitute the DMZ client's actual DHCP lease:

```bash
sudo ip netns exec router-trusted nix run nixpkgs#iperf3 -- -4 -c 10.77.20.100
sudo ip netns exec router-trusted nix run nixpkgs#iperf3 -- -4 -c 10.77.20.100 -R
```

The ASIX AX88179B PC adapters negotiate 1Gbps Ethernet. USB 3 avoids the
previous USB 2 bottleneck, but these adapters cannot validate 2.5Gbps speeds.
The built-in Pi upstream interface is also limited to 1Gbps.
