{
  nixos = {
    networking = {
      useNetworkd = true;
      useDHCP = false;
      dhcpcd.enable = false;

      # Bring up IPv4 first; IPv6 needs its own prefix delegation and zone policy.
      enableIPv6 = false;

      # The upstream module enables IPv4 forwarding as well as masquerading.
      nat = {
        enable = true;
        externalInterface = "end0";
        internalInterfaces = [
          "enP1p3s0"
          "enP1p4s0"
        ];
      };
    };

    systemd.network = {
      config.networkConfig.IPv4Forwarding = true;

      links = {
        # These RTL8125s have no readable factory MAC. Match PCI paths, not
        # randomly assigned addresses, and give each port a stable local MAC.
        "10-router-dmz" = {
          matchConfig.Path = "platform-1000110000.pcie-pci-0001:03:00.0";
          linkConfig = {
            Name = "enP1p3s0";
            MACAddressPolicy = "none";
            MACAddress = "02:77:20:00:00:01";
          };
        };
        "10-router-trusted" = {
          matchConfig.Path = "platform-1000110000.pcie-pci-0001:04:00.0";
          linkConfig = {
            Name = "enP1p4s0";
            MACAddressPolicy = "none";
            MACAddress = "02:77:10:00:00:01";
          };
        };
      };

      networks = {
        "10-upstream" = {
          matchConfig.Name = "end0";
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = false;
            LinkLocalAddressing = "no";
          };
          dhcpV4Config.ClientIdentifier = "mac";
        };
        "20-dmz" = {
          matchConfig.Name = "enP1p3s0";
          address = [ "10.77.20.1/24" ];
          linkConfig.RequiredForOnline = "no";
          networkConfig = {
            DHCP = "no";
            IPv6AcceptRA = false;
            LinkLocalAddressing = "no";
            ConfigureWithoutCarrier = true;
          };
        };
        "20-trusted" = {
          matchConfig.Name = "enP1p4s0";
          address = [ "10.77.10.1/24" ];
          linkConfig.RequiredForOnline = "no";
          networkConfig = {
            DHCP = "no";
            IPv6AcceptRA = false;
            LinkLocalAddressing = "no";
            ConfigureWithoutCarrier = true;
          };
        };
      };
    };
  };
}
