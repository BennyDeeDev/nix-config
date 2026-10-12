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

    local function focus(direction)
      local window = hs.window.focusedWindow()
      if window then
        window[direction](window)
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

    bind("h", function() focus("focusWindowWest") end)
    bind("j", function() focus("focusWindowSouth") end)
    bind("k", function() focus("focusWindowNorth") end)
    bind("l", function() focus("focusWindowEast") end)

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
