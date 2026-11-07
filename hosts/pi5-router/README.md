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

The stateful nftables firewall allows both networks to reach the internet.
New connections between trusted and DMZ are blocked in both directions; add
service-specific port permissions when needed rather than a blanket allowance.
New upstream connections into DMZ are also blocked. A single custom rule
blocks DMZ forwarding to the three RFC 1918 private IPv4 ranges, including
trusted and the Fritz!Box network. It precedes the forwarding permissions
added by the NAT module, which would otherwise allow DMZ to reach upstream
private devices. Established replies are allowed. Strict reverse path
filtering validates source addresses against their return routes.

Router DNS and DHCP are available on both downstream interfaces. SSH is
temporarily open on all interfaces through `services.openssh.openFirewall`.
The trusted interface also explicitly allows TCP 22: setting the global SSH
toggle to `false` later leaves trusted SSH available while closing WAN and
DMZ SSH. Do that before public exposure; until then DMZ clients can reach
router SSH despite forwarding isolation. Diagnostic pings remain allowed.

Keep this behind the Fritz!Box without Exposed Host or public port forwards.
WireGuard is prepared but not imported pending keys and peer details. Published
DMZ services are not configured yet.

## WireGuard management

[`wireguard.nix`](wireguard.nix) contains the upstream WireGuard interface and
SOPS key settings. It is not imported by `default.nix` yet. The interface's
firewall, networkd, and DNS settings live in their existing files:
[`firewall.nix`](firewall.nix), [`networking.nix`](networking.nix), and
[`dnsmasq.nix`](dnsmasq.nix). UDP 51820 is allowed on `end0`, but the Fritz!Box
still has no port forward or Exposed Host configured. There are no custom
options, enable guards or configuration-merging wrappers.

When enabled:

| Item | Configuration |
| --- | --- |
| Router interface | `wg0`, `10.77.30.1/24` |
| First client | `10.77.30.2/32`; subsequent clients use unique addresses |
| Listener | UDP 51820 on `end0` |
| Router access | All services |
| Trusted/DMZ access | All services on routed hosts |
| Internet/upstream forwarding | Not allowed through the VPN |

WireGuard peers are trusted on the router and may forward any protocol to
trusted and DMZ hosts. The existing trusted/DMZ isolation policy is unchanged;
VPN peers do not get a route to the Fritz!Box or internet. Established replies
to VPN connections are accepted. dnsmasq serves local and external DNS through
`10.77.30.1`; it does not serve DHCP on the VPN. Client VPN addresses are
static.

### Pending keys and peers

Create `secrets/pi5-router.yaml` with SOPS, using the prepared recipient rule
for the router and both YubiKeys. Its decrypted YAML must contain:

```yaml
wireguard-private-key: <ROUTER_PRIVATE_KEY>
```

Do not commit plaintext private keys or put them in Nix configuration. Client
private keys stay on their respective devices; only client public keys belong
on the router. No keys or encrypted placeholder file have been generated.

Once the real encrypted file and client public key are available, the host
supplies the SOPS source and native upstream peer settings. The SOPS source is
already set in `wireguard.nix`. Add the desktop peer there when its public key
is available:

```nix
networking.wireguard.interfaces.wg0.peers = [
  {
    publicKey = "<DESKTOP_PUBLIC_KEY>";
    allowedIPs = [ "10.77.30.2/32" ];
  }
];
```

The router's `wireguard.nix` uses upstream `networking.wireguard` options and
sets its SOPS-backed `privateKeyFile` directly. The shared
`modules/wireguard.nix` is for clients: it holds the common router endpoint,
router public key, client `allowedIPs`, and keepalive settings. Each client
host supplies only its own SOPS source and tunnel IP. Replace the router public
key placeholder in that shared module after generating the router keypair.

Bind `wireguard = import ./wireguard.nix;` in the existing `default.nix` `let`,
then add `wireguard.nixos` to its imports after the encrypted router key file
is ready. The feature file sets `networking.wireguard.enable = true`.

The SOPS secret is passed to networkd through systemd credentials. Key
rotation restarts networkd to reload the credential. Give each client a
unique key and VPN `/32` in the router peer's `allowedIPs`; do not put default
or LAN-subnet routes there. There is no custom peer schema or validation
layer; these are the upstream WireGuard options.

### Client configuration and local validation

The initial desktop config routes the trusted, DMZ, and VPN subnets through
the tunnel. DNS stays unchanged; query the router explicitly while testing:

```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.77.30.2/32

[Peer]
PublicKey = <ROUTER_PUBLIC_KEY>
Endpoint = 192.168.178.2:51820
AllowedIPs = 10.77.10.0/24, 10.77.20.0/24, 10.77.30.0/24
PersistentKeepalive = 25
```

Trusted, DMZ, and VPN traffic is routed through WireGuard. The Fritz!Box
subnet (`192.168.178.0/24`) is deliberately excluded because it contains the
WireGuard endpoint; ordinary internet and DNS traffic stay on the desktop's
existing routes. Do not enable Exposed Host or public port forwarding for this
test.

After supplying keys and deploying, first test from Fritz!Box Wi-Fi/LAN:

1. Check `networkctl status wg0` and the handshake on the Pi:

   ```bash
   sudo nix run nixpkgs#wireguard-tools -- show wg0
   sudo nix run nixpkgs#wireguard-tools -- show wg0 public-key
   ```

2. Ping `10.77.30.1`, query DNS explicitly, and log in:

   ```bash
   dig @10.77.30.1 pi5-router.home.arpa
   ssh benjamin@10.77.30.1
   ```

3. Verify access to intended services on trusted and DMZ hosts. VPN peers are
   not restricted by port, while trusted/DMZ isolation remains in effect.
4. Confirm the client's normal internet default route is unchanged.
5. Only after actual SSH management through the tunnel works, set
   `services.openssh.openFirewall = false` in `firewall.nix`. Trusted and
   WireGuard retain explicit SSH allowances; WAN and DMZ lose global SSH.
6. Reboot with working recovery access and repeat the tests before public
   exposure.

## Fritz!Box IPv4 address range

The [FRITZ!Box 7530 AX documentation][fritz-ipv4] gives these factory defaults:

| Purpose | Address or range |
| --- | --- |
| Upstream network | `192.168.178.0/24` |
| Fritz!Box gateway | `192.168.178.1` |
| Automatic DHCP pool | `192.168.178.20`–`192.168.178.200` inclusive |
| Addresses below the DHCP pool | `192.168.178.2`–`192.168.178.19` |
| Intended Pi DHCP reservation | `192.168.178.2` |

The Pi remains a WAN DHCP client. The Fritz!Box supports reservations outside
its automatic pool, so `.2` can be assigned through DHCP without configuring
a static address on the Pi. Confirm that `.2` is unused and check the actual
pool before setting up the reservation:

1. Open **Home Network → Network** in the Fritz!Box.
2. Edit the Pi with built-in Ethernet MAC `2c:cf:67:1c:66:fa`.
3. Set its IPv4 address to `192.168.178.2` and enable **Always assign this
   network device the same IPv4 address**.
4. Apply; the Pi receives `.2` on a subsequent DHCP lease renewal.

The address, gateway and router DNS are learned through WAN DHCP. UDP 68
remains allowed on `end0` for DHCP replies, including with a reservation.
Another upstream DHCP server can provide its own WAN configuration without
this Fritz!Box reservation. Downstream DHCP for trusted and DMZ is independent.

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

The base router needs `secrets/shared.yaml` for the password configured by
the Pi profile. WireGuard additionally needs `secrets/pi5-router.yaml` when
enabled. Apply the shared recipient change using an enrolled YubiKey on the PC:

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

Changing network management or the WAN address may briefly interrupt SSH.
The commands below use the observed bootstrap DHCP address `192.168.178.54`;
verify it before deployment. After the Fritz!Box reservation takes effect,
the WAN address becomes `192.168.178.2`; use the current lease for the build
and target host.

Build on the Pi first so downloading and building do not use the rollback
window:

```bash
nixos-rebuild build --flake .#pi5-router \
  --build-host benjamin@192.168.178.54 \
  --target-host benjamin@192.168.178.54
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

Reconnect using `pi5-router.fritz.box` or the current lease shown in the
Fritz!Box; a cached hostname record may briefly retain the previous address.
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
4. New connections to listening servers fail between trusted and DMZ in both
   directions until a service-specific exception is configured.
5. New upstream connections to a listening DMZ server fail.
6. DMZ cannot reach listening services on the upstream private network.
7. Router SSH remains available from trusted, DMZ and upstream during the lab.
   Once the global SSH toggle is disabled, verify that only trusted SSH works.
8. Repeat connectivity and isolation checks after a coordinated router reboot.

Use live listening servers and positive control connections when testing
blocked paths, so an absent service is not mistaken for a firewall block.
Inspect firewall counters on the router to confirm the expected drop rule.
The old private-upstream NAT benchmark is intentionally blocked from DMZ now;
do not weaken the policy just to repeat that benchmark.

To benchmark an explicitly allowed service port later, run a server in the
DMZ client (the default policy intentionally blocks this test):

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

[fritz-ipv4]: https://fritz.com/en/apps/knowledge-base/FRITZ-Box-7530-AX/201_configuring-the-fritz-box-to-always-assign-the-same-ip-address-to-a-network-device
