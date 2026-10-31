{
  nixos = {
    services.home-assistant = {
      lovelaceConfig = {
        views = [
          {
            title = "Infrastructure";
            path = "services";
            type = "sections";
            max_columns = 3;
            sections = [
              {
                type = "grid";
                column_span = 3;
                cards = [
                  {
                    type = "heading";
                    heading = "System Monitor";
                    icon = "mdi:monitor-dashboard";
                  }
                  {
                    type = "custom:auto-entities";
                    grid_options.columns = "full";
                    card = {
                      type = "custom:layout-card";
                      layout_type = "custom:grid-layout";
                      layout = {
                        "grid-template-columns" = "repeat(4, minmax(0, 1fr))";
                        mediaquery."(max-width: 700px)"."grid-template-columns" = "repeat(2, minmax(0, 1fr))";
                      };
                    };
                    card_param = "cards";
                    filter.include = [
                      {
                        integration = "systemmonitor";
                        domain = "sensor";
                        name = "/^System Monitor Processor use$/";
                        options = {
                          type = "tile";
                          name = "CPU";
                        };
                      }
                      {
                        integration = "systemmonitor";
                        domain = "sensor";
                        name = "/^System Monitor Memory usage$/";
                        options = {
                          type = "tile";
                          name = "RAM";
                        };
                      }
                      {
                        integration = "systemmonitor";
                        domain = "sensor";
                        name = "/^System Monitor Disk usage \\/$/";
                        options = {
                          type = "tile";
                          name = "Disk";
                        };
                      }
                      {
                        integration = "systemmonitor";
                        domain = "sensor";
                        name = "/^System Monitor Load \\(1 min\\)$/";
                        options = {
                          type = "tile";
                          name = "Load";
                        };
                      }
                    ];
                    show_empty = false;
                  }
                ];
              }
              {
                type = "grid";
                column_span = 3;
                cards = [
                  {
                    type = "heading";
                    heading = "Service Health";
                    icon = "mdi:server-network";
                  }
                  {
                    type = "custom:auto-entities";
                    grid_options.columns = "full";
                    card = {
                      type = "custom:layout-card";
                      layout_type = "custom:grid-layout";
                      layout = {
                        "grid-template-columns" = "repeat(4, minmax(0, 1fr))";
                        mediaquery."(max-width: 700px)"."grid-template-columns" = "repeat(2, minmax(0, 1fr))";
                      };
                    };
                    card_param = "cards";
                    filter.include = [
                      {
                        integration = "gatus";
                        domain = "binary_sensor";
                        options = {
                          type = "tile";
                          tap_action.action = "more-info";
                        };
                      }
                    ];
                    sort.method = "name";
                    show_empty = false;
                  }
                ];
              }
            ];
          }
        ];
      };

      config.lovelace.dashboards.nixos-lovelace = {
        mode = "yaml";
        filename = "ui-lovelace.yaml";
        title = "Infrastructure";
        icon = "mdi:view-dashboard";
        show_in_sidebar = true;
      };
    };
  };
}
