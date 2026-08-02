-- Desktop preset: monitors, startup, and app placements

hl.monitor({ -- ASUS
  output = "DP-2",
  mode = "1920x1200@60",
  position = "-1200x-240",
  scale = 1,
  transform = 3,
})

hl.monitor({ -- AOC 1440p (landscape: width x height; 1440x2560 is portrait and breaks without matching transform)
  output = "DP-3",
  mode = "2560x1440@180",
  position = "0x0",
  scale = 1,
})

hl.monitor({ -- AOC 1080p
  output = "DP-1",
  mode = "1920x1080@180",
  position = "2560x180",
  scale = 1,
})

hl.on("hyprland.start", function()
  hl.exec_cmd("[workspace 3 silent] zen-browser")
  hl.exec_cmd("[workspace 2 silent] equibop")
  hl.exec_cmd("sleep 1 && hyprctl dispatch workspace 2")
end)
