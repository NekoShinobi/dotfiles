-- Hyprland 0.55+ Lua configuration.
-- Migrated from hyprland.conf; the original file is retained as a rollback copy.

local terminal = "wezterm"
local fileManager = "nautilus"
local menu = "walker"
local htop = "GDK_BACKEND=x11 WEBKIT_DISABLE_DMABUF_RENDERER=1 NeoHtop"
local mainMod = "SUPER"
local ipc = "noctalia msg "

-- Monitor
hl.monitor({
	output = "eDP-2",
	mode = "2560x1600@120",
	position = "0x0",
	scale = 1,
})

-- Environment
hl.env("XCURSOR_SIZE", "18")
hl.env("HYPRCURSOR_SIZE", "18")
hl.env("HYPRCURSOR_THEME", "bocchi")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Autostart
hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("walker --gapplication-service")
	hl.exec_cmd("noctalia")
	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("fcitx5")
	hl.exec_cmd(
		"rclone mount --vfs-cache-mode writes --vfs-cache-max-age 5s --attr-timeout 5s --dir-cache-time 5s --daemon cpp-rw: homedata"
	)
end)

-- Look and feel
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
		col = {
			active_border = {
				colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
				angle = 45,
			},
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 20,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 2,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
	},
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "master",
	},
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
		middle_click_paste = false,
	},
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 2,
		sensitivity = -1,
		touchpad = {
			natural_scroll = false,
			scroll_factor = 0.5,
		},
	},
	debug = {
		disable_logs = false,
		enable_stdout_logs = true,
	},
})

-- Curves and animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("overshoot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2.83, bezier = "overshoot", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Persistent workspaces
for i = 1, 5 do
	hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

-- Layer rules
hl.layer_rule({
	name = "wleave-layerrule",
	match = { namespace = "wleave" },
	blur = true,
	dim_around = true,
	ignore_alpha = 0.5,
})

hl.layer_rule({
	name = "walker-blur-layerrule",
	match = { namespace = "walker" },
	blur = true,
	dim_around = true,
	ignore_alpha = 0.5,
	animation = "popin",
})

hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
	},
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

-- Input devices and gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

-- Noctalia
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. "settings-open"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(ipc .. "panel-toggle noctalia/wallhaven:browser"))

-- Programs
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(terminal .. " start --class yazi -- yazi"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))
hl.bind(mainMod .. " + CTRL + SHIFT + S", hl.dsp.exec_cmd("flameshot gui"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/wlogout.sh"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("hyprpicker | clipse -a"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("zeditor"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + B", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.pin())

local directions = {
	H = "left",
	L = "right",
	K = "up",
	J = "down",
}
for key, direction in pairs(directions) do
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = direction }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = direction }))
end

hl.bind(mainMod .. " + U", hl.dsp.window.resize({ x = -2, y = 0, relative = true }))
hl.bind(mainMod .. " + I", hl.dsp.window.resize({ x = 0, y = 2, relative = true }))
hl.bind(mainMod .. " + O", hl.dsp.window.resize({ x = 0, y = -2, relative = true }))
hl.bind(mainMod .. " + P", hl.dsp.window.resize({ x = 2, y = 0, relative = true }))

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + D", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media and brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 4%+"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ repeating = true, locked = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 4%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 4%-"), { repeating = true, locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Window rules
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

local centeredWindows = {
	{ name = "clipse", class = "clipse" },
	{ name = "pavucontrol", class = "pavucontrol" },
	{ name = "wiremix", class = "Wiremix" },
	{ name = "impala", class = "Impala" },
	{ name = "fastfetch", class = "fastfetch" },
}
for _, rule in ipairs(centeredWindows) do
	hl.window_rule({
		name = rule.name,
		match = { class = rule.class },
		float = true,
		center = true,
		size = { 800, 640 },
	})
end

hl.window_rule({
	name = "jdslabs",
	match = { class = "^(com[.]jdslabs[.]core|JDS Labs Core)$" },
	pseudo = true,
	center = true,
	size = { 800, 640 },
	opacity = "0.9",
})

-- Keep Bitwarden pseudotiled at its requested size.
hl.window_rule({
	name = "bitwarden-pseudo",
	match = { class = "^Bitwarden$" },
	pseudo = true,
})

hl.window_rule({
	name = "noctalia-settings-float",
	match = { class = "^dev[.]noctalia[.]Noctalia$", title = "^Noctalia Settings$" },
	float = true,
})

hl.window_rule({
	name = "poe-rule",
	match = { class = "^(PathOfExileSteam.exe|pathofexilesteam.exe|steam_app_238960|steam_app_2694490)$" },
	tile = true,
	float = true,
	content = "game",
})

hl.window_rule({
	name = "apt-rule",
	match = { class = "^(awakened-poe-trade|Awakened-poe-trade)$" },
	float = true,
	border_size = 0,
	no_blur = true,
	no_shadow = true,
	no_anim = true,
	no_follow_mouse = true,
})

hl.window_rule({
	name = "ee2",
	match = { title = "(Exiled Exchange 2)" },
	no_blur = true,
})

hl.window_rule({
	name = "background-games",
	match = { class = "^steam_app_default$" },
	render_unfocused = true,
})

-- Generated Noctalia colors are kept in their own protected module.
require("noctalia/noctalia-colors")

-- For Noctalia Color templates
require("noctalia").apply_theme()
