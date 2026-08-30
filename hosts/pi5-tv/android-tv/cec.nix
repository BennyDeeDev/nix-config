{
  nixos =
    {
      lib,
      pkgs,
      ...
    }:
    let
      cecInput = "/dev/input/by-path/platform-107c701400.hdmi-event";
      cecMount = "lxc.mount.entry = ${cecInput} dev/input/event1 none bind,create=file,optional 0 0";
      cecCtl = lib.getExe' pkgs.v4l-utils "cec-ctl";
      setupCec = pkgs.writeShellScript "android-tv-waydroid-cec" ''
        set -eu

        config_nodes=/var/lib/waydroid/lxc/waydroid/config_nodes

        if test -e ${lib.escapeShellArg cecInput} \
          && ! ${lib.getExe pkgs.gnugrep} -Fqx ${lib.escapeShellArg cecMount} "$config_nodes"; then
          printf '%s\n' ${lib.escapeShellArg cecMount} >> "$config_nodes"
        fi
      '';
      announceCecSource = pkgs.writeShellScript "android-tv-cec-source" ''
        set -eu

        attempts=0
        while test "$attempts" -lt 30; do
          if test -e /dev/cec0 \
            && ${cecCtl} --device /dev/cec0 --playback --osd-name NixOS-TV \
              --active-source phys-addr=2.0.0.0 --to 0 --image-view-on; then
            exit 0
          fi
          ${lib.getExe' pkgs.coreutils "sleep"} 1
          attempts=$((attempts + 1))
        done

        echo "HDMI-CEC source announcement failed" >&2
        exit 1
      '';
    in
    {
      services.udev.extraRules = ''
        KERNEL=="event*", KERNELS=="107c701400.hdmi", GROUP="input", MODE="0660"
      '';

      services.udev.extraHwdb = ''
        evdev:name:vc4-hdmi-0:*
         KEYBOARD_KEY_00=enter
         KEYBOARD_KEY_0d=back
      '';

      systemd.services.waydroid-container.serviceConfig.ExecStartPre = lib.mkAfter [ setupCec ];

      systemd.services.android-tv-cec-source = {
        description = "Announce the Pi as the active HDMI-CEC source";
        wantedBy = [ "graphical.target" ];
        after = [ "cage-tty1.service" ];
        serviceConfig = {
          ExecStart = announceCecSource;
          Type = "oneshot";
        };
      };
    };
}
