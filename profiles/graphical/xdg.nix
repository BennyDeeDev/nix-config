{
  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf pkgs.stdenv.isLinux {
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        pictures = "${config.home.homeDirectory}/Pictures";
        music = "${config.home.homeDirectory}/Music";
        videos = "${config.home.homeDirectory}/Videos";
        desktop = "${config.home.homeDirectory}/Desktop";
        templates = "${config.home.homeDirectory}/Templates";
        publicShare = "${config.home.homeDirectory}/Public";
        extraConfig = {
          REPOS = "${config.home.homeDirectory}/Repos";
          BACKUPS = "${config.home.homeDirectory}/Backups";
          VMS = "${config.home.homeDirectory}/VMs";
        };
      };

      xdg.configFile."gtk-3.0/bookmarks" = {
        force = true;
        text = ''
          file://${config.home.homeDirectory}/Documents
          file://${config.home.homeDirectory}/Downloads
          file://${config.home.homeDirectory}/Pictures
          file://${config.home.homeDirectory}/Repos
          file://${config.home.homeDirectory}/Backups
        '';
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "brave-browser.desktop";
          "x-scheme-handler/http" = "brave-browser.desktop";
          "x-scheme-handler/https" = "brave-browser.desktop";
          "x-scheme-handler/mailto" = "brave-browser.desktop";

          "image/png" = "org.gnome.Loupe.desktop";
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/gif" = "org.gnome.Loupe.desktop";
          "image/webp" = "org.gnome.Loupe.desktop";
          "image/bmp" = "org.gnome.Loupe.desktop";
          "image/tiff" = "org.gnome.Loupe.desktop";

          "application/pdf" = "org.gnome.Papers.desktop";

          "video/mp4" = "org.gnome.Showtime.desktop";
          "video/x-msvideo" = "org.gnome.Showtime.desktop";
          "video/x-matroska" = "org.gnome.Showtime.desktop";
          "video/x-flv" = "org.gnome.Showtime.desktop";
          "video/x-ms-wmv" = "org.gnome.Showtime.desktop";
          "video/mpeg" = "org.gnome.Showtime.desktop";
          "video/ogg" = "org.gnome.Showtime.desktop";
          "video/webm" = "org.gnome.Showtime.desktop";
          "video/quicktime" = "org.gnome.Showtime.desktop";
          "video/3gpp" = "org.gnome.Showtime.desktop";
          "video/3gpp2" = "org.gnome.Showtime.desktop";
          "video/x-ms-asf" = "org.gnome.Showtime.desktop";
          "video/x-ogm+ogg" = "org.gnome.Showtime.desktop";
          "video/x-theora+ogg" = "org.gnome.Showtime.desktop";
          "application/ogg" = "org.gnome.Showtime.desktop";

          "text/plain" = "code.desktop";
          "text/x-makefile" = "code.desktop";
          "text/x-c++hdr" = "code.desktop";
          "text/x-c++src" = "code.desktop";
          "text/x-chdr" = "code.desktop";
          "text/x-csrc" = "code.desktop";
          "text/x-java" = "code.desktop";
          "text/x-pascal" = "code.desktop";
          "text/x-tcl" = "code.desktop";
          "text/x-tex" = "code.desktop";
          "text/x-c" = "code.desktop";
          "text/x-c++" = "code.desktop";
          "text/xml" = "code.desktop";
          "application/xml" = "code.desktop";
          "application/x-shellscript" = "code.desktop";
        };
      };
    };
}
