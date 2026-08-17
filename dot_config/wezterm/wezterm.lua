local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 初回起動時にウィンドウを最大化する
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local function basename(s)
	return (s:gsub("(.*[/\\])(.*)", "%2"))
end

wezterm.on("format-tab-title", function(tab)
	local pane = tab.active_pane
	local proc = pane.foreground_process_name ~= "" and basename(pane.foreground_process_name) or ""
	local cwd = pane.current_working_dir
	local dir = cwd and basename(cwd.file_path or "") or ""
	return " " .. dir .. " " .. proc .. " "
end)
config.font = wezterm.font("UDEV Gothic 35")
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.font_size = 12.0
config.line_height = 1.1
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.colors = {
	foreground = "#cdcdcd",
	background = "#141415",
	cursor_bg = "#cdcdcd",
	cursor_fg = "#141415",
	cursor_border = "#cdcdcd",
	selection_fg = "#cdcdcd",
	selection_bg = "#252530",
	split = "#252530",
	ansi = { "#252530", "#d8647e", "#7fa563", "#f3be7c", "#6e94b2", "#bb9dbd", "#aeaed1", "#cdcdcd" },
	brights = { "#606079", "#e08398", "#99b782", "#f5cb96", "#8ba9c1", "#c9b1ca", "#bebeda", "#d7d7d7" },
	tab_bar = {
		active_tab = { bg_color = "#252530", fg_color = "#cdcdcd" },
		inactive_tab = { bg_color = "#141415", fg_color = "#606079" },
		inactive_tab_hover = { bg_color = "#252530", fg_color = "#cdcdcd" },
		new_tab = { bg_color = "#141415", fg_color = "#6e94b2" },
		new_tab_hover = { bg_color = "#252530", fg_color = "#8ba9c1" },
		inactive_tab_edge = "#252530",
	},
}
config.window_frame = { active_titlebar_bg = "#141415", inactive_titlebar_bg = "#141415" }
config.scrollback_lines = 10000
config.max_fps = 120
config.quick_select_patterns = { "[\\w.\\-/]+:\\d+" }

config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.6,
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
	{ key = "Enter", mods = "SUPER", action = wezterm.action.SendString("\x1b[13;3u") },
	{ key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
	{ key = "/", mods = "LEADER", action = wezterm.action.Search({ CaseInSensitiveString = "" }) },
	{ key = "r", mods = "LEADER", action = wezterm.action.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
}

config.key_tables = {
	resize_pane = {
		{ key = "h", action = wezterm.action.AdjustPaneSize({ "Left", 3 }) },
		{ key = "j", action = wezterm.action.AdjustPaneSize({ "Down", 3 }) },
		{ key = "k", action = wezterm.action.AdjustPaneSize({ "Up", 3 }) },
		{ key = "l", action = wezterm.action.AdjustPaneSize({ "Right", 3 }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

return config
