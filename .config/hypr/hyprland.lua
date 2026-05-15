-- Hyprland Lua configuration
-- See https://wiki.hypr.land/Configuring/Start/

-- Variables
local terminal = "kitty"
local fileManager = "thunar"
local menu = "wofi --conf /home/nyx/.config/wofi/config --style /home/nyx/.config/wofi/style.css"

-- Expose variables to modules
_G.terminal = terminal
_G.fileManager = fileManager
_G.menu = menu

-- Detect whether Nvidia GPU is present (desktop vs laptop)
local function has_nvidia()
  local f = io.open("/proc/modules", "r")
  if f then
    for line in f:lines() do
      if line:match("^nvidia ") then
        f:close()
        return true
      end
    end
    f:close()
  end
  return false
end

_G.is_desktop = has_nvidia()

-- Environment variables
-- QT
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_STYLE_OVERRIDE", "qt5ct-style")
hl.env("QT_QPA_PLATFORM", "wayland")

-- Cursor
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- GDK
hl.env("GDK_BACKEND", "wayland")

-- Other
hl.env("EDITOR", "nvim")

-- Ecosystem
hl.config({
    ecosystem = {
        no_update_news = true
    }
})

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprsunset -t 3000")
    hl.exec_cmd("hyprctl setcursor catppuccin-mocha-pink-cursors 24")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hash dbus-update-activation-environment 2>/dev/null &")
    hl.exec_cmd("dbus-update-activation-environment &")
end)

-- Appearance & behavior
hl.config({
    cursor = {
        no_hardware_cursors = true
    },
    general = {
        gaps_in = 2,
        gaps_out = 3,
        border_size = 1,
        col = {
            active_border = "rgba(cba6f7FF)",
            inactive_border = "rgba(45475aFF)",
        },
        resize_on_border = false,
        allow_tearing = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = false,
        },
        shadow = {
            enabled = false,
        },
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        vrr = 1,
    },
    input = {
        kb_layout = "pl",
        follow_mouse = 1,
        mouse_refocus = false,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
        touchdevice = {
            enabled = false,
        },
    },
})

-- Animation curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0}  } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Animations
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",      style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",      style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Load machine-specific preset (desktop or laptop)
if _G.is_desktop then
  require("modules.desktop")
  require("modules.nvidia")
else
  require("modules.laptop")
end

require("keybindings")
