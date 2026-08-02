-- Laptop preset: monitors, startup, and app placements

hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
})

hl.on("hyprland.start", function()
  -- Laptop-specific startup apps
  hl.exec_cmd("python /home/nyx/.config/hypr/monitor-switcher.py")
end)

-- Laptop-only keybindings
hl.bind("SUPER + CONTROL + O", hl.dsp.exec_cmd("/home/nyx/notes/nopen.sh"))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("~/.config/hypr/toggle-touch.sh"))
