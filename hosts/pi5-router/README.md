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

dnsmasq serves DHCP and DHCP lease names under `home.arpa` on the two
downstream interfaces, and DNS on those interfaces and both VPNs. It forwards
external DNS queries to the Fritz!Box at `192.168.178.1`. The router uses
networkd/resolved for its own DNS.

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
Both WireGuard features are enabled in this configuration. Published DMZ
services are not configured yet.

## Network monitoring

[`ntopng.nix`](ntopng.nix) monitors the router's separate upstream (`end0`),
DMZ (`enP1p3s0`), and trusted (`enP1p4s0`) interfaces; there is no `br-lan`
bridge. The NixOS ntopng module also enables its local Redis instance.

From trusted or either VPN, open `http://10.77.10.1:3000`. The firewall allows
TCP 3000 on the trusted interface; the VPN interfaces are already trusted.
The port is not opened on the upstream or DMZ interfaces. The NixOS module's
initial login is `admin` / `admin`; change it immediately on first login. This
UI uses HTTP, so keep access on the trusted network or VPN.

## WireGuard management

Each interface has one owner. NixOS/networkd manages declarative `wg0` through
[`wireguard.nix`](wireguard.nix). `wg-access-server` owns `wg1`, its addresses,
and UI-enrolled peers through [`wg-access-server.nix`](wg-access-server.nix).
Both feature files are imported by `default.nix`; router secrets live in
`secrets/pi5-router.yaml`. macOS client configuration is out of scope.

| Item | Declarative VPN | UI-managed VPN |
| --- | --- | --- |
| Router interface | `wg0`, `10.77.30.1/24` | `wg1`, `10.77.40.1/24` |
| Clients | Desktop `10.77.30.2/32` | UI assigns addresses in `10.77.40.0/24` |
| Listener | UDP 51820 | UDP 51821 |
| Client `AllowedIPs` | `0.0.0.0/0` | `0.0.0.0/0` |
| DNS | `10.77.30.1` | `10.77.40.1` |

Both VPNs are trusted for all router services and may initiate connections to
trusted, DMZ, other VPN peers, and upstream networks, including the internet.
Destination hosts must still allow the service in their own firewalls. Existing
trusted/DMZ isolation is unchanged; replies to VPN connections are statefully
accepted.

[`firewall.nix`](firewall.nix), [`networking.nix`](networking.nix), and
[`dnsmasq.nix`](dnsmasq.nix) contain the shared firewall, NAT, networkd, and DNS
settings. NixOS masquerades both VPNs through `end0`; downstream/VPN traffic
is routed without NAT. `disableIPTables = true` prevents wg-access-server from
installing its own forwarding or NAT rules. dnsmasq serves DNS, not DHCP, on
both VPNs. networkd leaves application-owned `wg1` unmanaged.

UDP 51820 and 51821 are allowed on `end0`, but there is no Fritz!Box port
forward or Exposed Host. Endpoints use the intended Pi reservation
`192.168.178.2`. These VPNs are only reachable locally for now, not from mobile
data or outside home.

### Keys and peers

Keep router secrets together in `secrets/pi5-router.yaml`, encrypted for the
router and both YubiKeys. Its decrypted YAML contains:

```yaml
wireguard-private-key: <ROUTER_PRIVATE_KEY>
wg-access-server: |
  adminPassword: "<STRONG_ADMIN_PASSWORD>"
  wireguard:
    privateKey: "<SEPARATE_WG1_PRIVATE_KEY>"
  auth:
    sessionStore:
      secret: "<64_HEXADECIMAL_CHARACTERS>"
```

The `wg-access-server` value is a YAML block string. SOPS extracts that string
to the service's runtime `secretsFile`; the service does not receive the `wg0`
private key. The two server interfaces need separate keys. See
[WireGuard secrets](../../secrets/README.md#wireguard-secrets) for generation
and editing instructions. Do not commit plaintext keys or put them in Nix
configuration.

The desktop's `wg0` peer public key is declared in this router's
`wireguard.nix`:

```nix
networking.wireguard.interfaces.wg0.peers = [
  {
    publicKey = "pUMfraTQ/nRO71OgzsAxXZqEwUiOIEjvhJf2Zx60mB4=";
    allowedIPs = [ "10.77.30.2/32" ];
  }
];
```

Give each declarative client a unique key and VPN `/32` in the router peer's
`allowedIPs`; do not put default or LAN-subnet routes on server-side peers.
The router's `wg0` public key is configured in the desktop's
`hosts/desktop/wireguard.nix`; it is separate from the `wg1` public key
distributed by the UI. When rotating keys, update the corresponding peer's
public key too.

Deploy the router before activating the desktop profile described in the
[desktop guide](../desktop/README.md#wireguard-to-the-router).

The `wg0` SOPS secret reaches networkd through systemd credentials; changing
it restarts networkd. Changing the UI secrets restarts wg-access-server.

### UI enrollment and state

From trusted, open `https://10.77.10.1:8443` and sign in as `admin` with the
password from SOPS. Verify the self-signed certificate through a trusted
management connection before accepting the browser warning. HTTPS is allowed
from trusted and both VPNs, not WAN or DMZ. The pinned service also starts an
HTTP listener on TCP 8000; it is not opened on trusted, WAN, or DMZ. Trusted
VPN interfaces can reach all router services; use HTTPS for enrollment.

Add devices through the UI and download their configuration or scan the QR
code. Profiles advertise endpoint `192.168.178.2:51821`, DNS `10.77.40.1`, and
`AllowedIPs = 0.0.0.0/0`. Exported profiles contain device private keys: keep
them off Git and do not share them. Revoke a device by deleting it in the UI.

Peer records and allocations persist in `/var/lib/wg-access-server/db.sqlite`
across restarts and rebuilds. Back up `/var/lib/wg-access-server` securely
while the service is stopped, plus the encrypted host secrets and the keys
needed to decrypt them. The state directory also contains the generated TLS
key and merged secret configuration; do not commit it.

### Client configuration and local validation

The desktop uses a declarative NetworkManager WireGuard profile with
autoconnect disabled. When connected, NetworkManager sends IPv4 internet
traffic through the Pi using policy routing while keeping encrypted WireGuard
packets on the physical connection. Its client settings are equivalent to:

```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.77.30.2/32
DNS = 10.77.30.1

[Peer]
PublicKey = <ROUTER_PUBLIC_KEY>
Endpoint = 192.168.178.2:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

This is IPv4-only. IPv6 routing and leak prevention are deferred, so IPv6 may
bypass the tunnel while connected. A full tunnel is not a kill switch: stopping
it restores ordinary IPv4 connectivity. More-specific local routes still take
precedence, including the Fritz!Box LAN while testing there; an overlapping
local subnet can prevent access to a home subnet through the VPN.
Application-specific DNS settings such as browser DoH can override system DNS.

After supplying keys and deploying, first test from Fritz!Box Wi-Fi/LAN:

Connect `wg0` from KDE's network tray widget, or run `nmcli connection up wg0`.
When finished testing, disconnect it from the widget or run
`nmcli connection down wg0`.

1. Check the router interfaces, service, and handshakes:

   ```bash
   networkctl status wg0
   systemctl status wg-access-server
   sudo nix run nixpkgs#wireguard-tools -- show wg0
   sudo nix run nixpkgs#wireguard-tools -- show wg1
   ```

2. From the desktop, ping `10.77.30.1`, query DNS, and log in:

   ```bash
   nix run nixpkgs#dig -- @10.77.30.1 pi5-router.home.arpa
   ssh benjamin@10.77.30.1
   ```

3. Verify access to intended services on trusted and DMZ hosts. VPN peers are
   not restricted by port, while trusted/DMZ isolation remains in effect.
4. Inspect `ip -4 rule` and `ip -4 route show table all` on the desktop; the
   main default route alone does not show NetworkManager's policy routing;
   confirm IPv4 traffic enters the Pi on the VPN and exits `end0`. A public IP
   check alone cannot prove this when both client and Pi use the Fritz!Box.
5. Enroll a UI device, verify its handshake, DNS, home-network access, and
   IPv4 internet access. Reboot to check profile persistence; delete the device
   and verify revocation. IPv6 bypass prevention is deferred.
6. Check HTTPS is blocked from WAN and DMZ, and repeat trusted/DMZ isolation
   tests. Use positive controls with listening services, not only ping.
7. Only after actual SSH management through the tunnel works, set
   `services.openssh.openFirewall = false` in `firewall.nix`. Trusted and
   WireGuard retain explicit SSH allowances; WAN and DMZ lose global SSH.
8. Reboot with working recovery access and repeat the tests. Do not configure
   public exposure as part of this setup.

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
the Pi profile. Both VPN features use `secrets/pi5-router.yaml` when enabled.
Apply the shared recipient change using an enrolled YubiKey on the PC:

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
