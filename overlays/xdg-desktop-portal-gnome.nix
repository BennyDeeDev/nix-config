# Work around xdg-desktop-portal 1.22.x forwarding duplicate Settings signals
# from GTK and GNOME under Niri. Remove once nixpkgs includes upstream fix:
# https://github.com/flatpak/xdg-desktop-portal/issues/2033
# https://github.com/flatpak/xdg-desktop-portal/pull/2048
final: prev: {
  xdg-desktop-portal-gnome = prev.xdg-desktop-portal-gnome.overrideAttrs (old: {
    # Keep GNOME's Niri portal support without forwarding duplicate Settings signals.
    postInstall = (old.postInstall or "") + ''
      substituteInPlace $out/share/xdg-desktop-portal/portals/gnome.portal \
        --replace-fail \
          "org.freedesktop.impl.portal.Settings;" \
          ""
    '';
  });
}
