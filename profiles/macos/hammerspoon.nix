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

    local function newFinderWindow()
      hs.osascript.applescript([[
        tell application "Finder"
          make new Finder window
          activate
        end tell
      ]])
    end

    local function newGhosttyWindow()
      hs.osascript.applescript([[
        tell application "Ghostty"
          activate
          set cfg to new surface configuration
          new window with configuration cfg
        end tell
      ]])
    end

    bind("h", hs.window.filter.focusWest)
    bind("j", hs.window.filter.focusSouth)
    bind("k", hs.window.filter.focusNorth)
    bind("l", hs.window.filter.focusEast)

    bind("t", function()
      moveFocusedWindow(hs.geometry.rect(0.1, 0, 0.8, 1))
    end)

    bind("g", newGhosttyWindow)
    bind("f", newFinderWindow)
    bind("p", launchOrFocus("KeePassXC"))
    bind(",", launchOrFocus("System Settings"))
    bind("s", launchOrFocus("Activity Monitor"))
  '';
}
