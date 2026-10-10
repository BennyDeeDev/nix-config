let
  fixedSpacer = {
    panelSpacer = {
      expanding = false;
      length = 10;
    };
  };

  expandingSpacer = {
    panelSpacer.expanding = true;
  };
in
{
  homeManager =
    { config, ... }:
    {
      programs.plasma.panels = [
        {
          location = "top";
          height = 32;
          floating = true;
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config.General.icon = config.my.kde.kickoffIcon;
            }
            fixedSpacer
            "org.kde.plasma.pager"
            expandingSpacer
            "org.kde.plasma.mediacontroller"
            expandingSpacer
            "org.kde.plasma.cameraindicator"
            fixedSpacer
            "org.kde.plasma.notifications"
            fixedSpacer
            "org.kde.plasma.brightness"
            fixedSpacer
            "org.kde.plasma.networkmanagement"
            fixedSpacer
            "org.kde.plasma.volume"
            fixedSpacer
            "org.kde.plasma.bluetooth"
            fixedSpacer
            "org.kde.plasma.battery"
            fixedSpacer
            {
              name = "org.kde.plasma.systemmonitor.cpu";
              config.Appearance.chartFace = "org.kde.ksysguard.piechart";
            }
            fixedSpacer
            {
              name = "org.kde.plasma.systemmonitor.memory";
              config.Appearance.chartFace = "org.kde.ksysguard.piechart";
            }
            fixedSpacer
            {
              name = "org.kde.plasma.systemmonitor.diskusage";
              config.Appearance.chartFace = "org.kde.ksysguard.piechart";
            }
            fixedSpacer
            "org.kde.plasma.marginsseparator"
            {
              digitalClock = {
                date = {
                  enable = true;
                  format = "longDate";
                };
                time = {
                  format = "24h";
                  showSeconds = "never";
                };
              };
            }
          ];
        }
        {
          location = "bottom";
          height = 64;
          floating = true;
          lengthMode = "fit";
          hiding = "autohide";
          widgets = [
            {
              iconTasks = {
                iconsOnly = true;
                launchers = [
                  "preferred://filemanager"
                  "applications:brave-browser.desktop"
                  "applications:com.mitchellh.ghostty.desktop"
                  "applications:code.desktop"
                  "applications:steam.desktop"
                  "applications:spotify.desktop"
                  "applications:org.keepassxc.KeePassXC.desktop"
                  "applications:systemsettings.desktop"
                  "applications:org.kde.plasma-systemmonitor.desktop"
                ];
                behavior = {
                  minimizeActiveTaskOnClick = false;
                  showTasks = {
                    onlyInCurrentActivity = false;
                    onlyInCurrentDesktop = false;
                  };
                };
              };
            }
          ];
        }
      ];
    };
}
