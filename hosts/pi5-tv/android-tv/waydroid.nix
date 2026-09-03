{
  nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      imageData = import ./image-data.nix { inherit pkgs; };
      waydroidInit = pkgs.writeShellScript "android-tv-waydroid-init" ''
        set -eu

        if ! test -e /var/lib/waydroid/waydroid.cfg; then
          ${lib.getExe config.virtualisation.waydroid.package} init -f
        fi
      '';
    in
    {
      virtualisation.waydroid.enable = true;
      virtualisation.waydroid.package = pkgs.waydroid-nftables;

      environment.etc."waydroid-extra/images/system.img".source = "${imageData.images}/system.img";
      environment.etc."waydroid-extra/images/vendor.img".source = "${imageData.images}/vendor.img";

      systemd.services.waydroid-container.serviceConfig.ExecStartPre = [ waydroidInit ];
    };
}
