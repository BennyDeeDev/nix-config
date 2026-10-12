{
  darwin.homebrew.casks = [ "hammerspoon" ];

  homeManager.home.file.".hammerspoon/init.lua".text = ''
    hs.window.animationDuration = 0

    local hyper = {"ctrl", "alt", "cmd"}

    local function bind(key, action)
      hs.hotkey.bind(hyper, key, action)
    end

    local function moveFocusedWindow(unitRect)
      local window = hs.window.focusedWindow()
      if window then
        window:moveToUnit(unitRect)
      end
    end

    local function launchOrFocus(app)
      return function()
        hs.application.launchOrFocus(app)
      end
    end

    bind("h", hs.window.filter.focusWest)
    bind("j", hs.window.filter.focusSouth)
    bind("k", hs.window.filter.focusNorth)
    bind("l", hs.window.filter.focusEast)

    hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "t", function()
      moveFocusedWindow(hs.geometry.rect(0.1, 0, 0.8, 1))
    end)

    bind("t", launchOrFocus("Ghostty"))
    bind("f", launchOrFocus("Finder"))
    bind("p", launchOrFocus("KeePassXC"))
    bind(",", launchOrFocus("System Settings"))
    bind("s", launchOrFocus("Activity Monitor"))
  '';
}
