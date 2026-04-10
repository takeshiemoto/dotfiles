local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.color_scheme = "iceberg-dark"
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"UDEV Gothic NF",
})
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.font_size = 12.0
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.97
config.macos_window_background_blur = 40

config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.4,
}

config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	{ key = "t", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
	{ key = "d", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
	{ key = "w", mods = "SUPER", action = wezterm.action.DisableDefaultAssignment },
	{ key = "\\", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b[13;2u") },
	{ key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
}

return config
