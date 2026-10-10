let
  monitorId = "4d81b63b-03d7-4e0c-9a8c-7146df8f34a0";
in
{
  homeManager.programs.plasma.kwin.tiling = {
    padding = 0;

    layout = {
      id = "Desktop_2/${monitorId}";

      tiles = {
        layoutDirection = "floating";
        tiles = [
          {
            x = 0.1;
            y = 0.0;
            width = 0.8;
            height = 1.0;
          }
        ];
      };
    };
  };
}
