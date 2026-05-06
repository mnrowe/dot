local wezterm = require("wezterm")
local mux = wezterm.mux

local pwsh = "C:\\Program Files\\PowerShell\\7\\pwsh.exe"

----------------------------- detect_os ----------------------------

local function detect_os()
	if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
		return "macos"
	elseif wezterm.target_triple == "x86_64-pc-windows-msvc" then
		return "windows"
	elseif wezterm.target_triple == "x86_64-unknown-linux-gnu" then
		return "linux"
	else
		return "unknown"
	end
end

local myos = detect_os()

--------------------------- detect_shell ---------------------------

local function detect_shell()
	if myos == "windows" then
		return { pwsh, "-NoLogo" }
	elseif myos == "macos" then
		return { "/opt/homebrew/bin/bash", "--login" }
	else
		return { "/bin/bash", "--login" }
	end
end

---------------------------- detect_font ---------------------------

local function detect_font()
	return wezterm.font("UbuntuMono Nerd Font Mono")
end

------------------------- startup layout ---------------------------

if myos == "windows" then
	wezterm.on("gui-startup", function(cmd)
		local tab, pane, window = mux.spawn_window({
			args = { pwsh, "-NoLogo" },
		})

		window:spawn_tab({
			args = { "wsl.exe", "--distribution", "Ubuntu" },
		})
	end)
end

------------------------------- main -------------------------------

return {
	window_decorations = myos == "linux" and "RESIZE" or "TITLE | RESIZE",
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = false,
	window_close_confirmation = "NeverPrompt",

	default_prog = detect_shell(),
	default_domain = "local",

	launch_menu = {
		{
			label = "PowerShell 7",
			args = { pwsh, "-NoLogo" },
		},
		{
			label = "Windows PowerShell",
			args = { "powershell.exe", "-NoLogo" },
		},
		{
			label = "WSL Ubuntu",
			args = { "wsl.exe", "--distribution", "Ubuntu" },
		},
	},

	keys = {
		{
			key = "l",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ShowLauncher,
		},
	},

	color_scheme = "Dracula (base16)",
	font = detect_font(),
	font_size = 14,

	colors = {
		cursor_bg = "#928374",
		cursor_border = "#928374",
	},

	window_padding = {
		left = 4,
		right = 0,
		top = 0,
		bottom = 2,
	},

	term = "xterm-256color",
	animation_fps = 60,
	max_fps = 60,
}
