local theme = {}

-- ##########################################################
-- #                     	IMPORTS      					#
-- ##########################################################

local theme_assets = require("beautiful.theme_assets")
local themes_path = "~/.config/awesome/themes/"
local with_dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")

-- ##########################################################
-- #                     GENERAL RICE 						#
-- ##########################################################

-- wallpaper
theme.wallpaper = themes_path .. "nord/deadly-blue-minimalism-nord3-16-10.png"

-- general font to use
theme.font      = "JetBrains Mono Bold 9"

-- colour scheme
theme.nord0  = "#2E3440"
theme.nord1  = "#3B4252"
theme.nord2  = "#434C5E"
theme.nord3  = "#4C566A"
theme.nord4  = "#D8DEE9"
theme.nord5  = "#E5E9F0"
theme.nord6  = "#ECEFF4"
theme.nord7  = "#8FBCBB"
theme.nord8  = "#88C0D0"
theme.nord9  = "#81A1C1"
theme.nord10 = "#5E81AC"
theme.nord11 = "#BF616A"
theme.nord12 = "#D08770"
theme.nord13 = "#EBCB8B"
theme.nord14 = "#A3BE8C"
theme.nord15 = "#B48EAD"

-- general colours
theme.fg_normal  = theme.nord6
theme.fg_focus   = theme.nord8
theme.fg_urgent  = theme.nord12
theme.bg_normal  = theme.nord0
theme.bg_focus   = theme.nord1
theme.bg_urgent  = theme.nord1
theme.bg_systray = theme.bg_normal

-- borders
theme.border_width  = with_dpi(1)
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.fg_focus
theme.border_marked = theme.fg_urgent

-- tasklist
theme.tasklist_bg_focus = theme.fg_focus

-- no base useless gap, but this may be overridden
-- on a tag-to-tag basis in rc.lua
theme.useless_gap   = with_dpi(0)

-- Mouse finder (no idea what this is)
theme.mouse_finder_color = theme.nord12
-- mouse_finder_[timeout|animate_timeout|radius|factor]

-- Menu pop-ups (e.g. Mod4+w and Mod4+c)
-- 		Variables set for theming the menu:
-- 		menu_[bg|fg]_[normal|focus]
-- 		menu_[border_color|border_width]
theme.menu_height = with_dpi(15)
theme.menu_width  = with_dpi(100)

-- ##########################################################
-- #                     TITLE BARS   						#
-- ##########################################################

-- titlebar colours
theme.titlebar_bg_focus   = theme.bg_focus
theme.titlebar_bg_normal  = theme.bg_normal

-- titlebar size
theme.titlebar_size = with_dpi(4)

-- ################### TITLEBAR ICONS #######################

theme.titlebar_close_button_focus  = themes_path .. "nord/titlebar/close_focus.png"
theme.titlebar_close_button_normal = themes_path .. "nord/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = themes_path .. "nord/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "nord/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path .. "nord/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = themes_path .. "nord/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = themes_path .. "nord/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "nord/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path .. "nord/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = themes_path .. "nord/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = themes_path .. "nord/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = themes_path .. "nord/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = themes_path .. "nord/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = themes_path .. "nord/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = themes_path .. "nord/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = themes_path .. "nord/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "nord/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = themes_path .. "nord/titlebar/maximized_normal_inactive.png"


-- ##########################################################
-- #                     	MENUBAR      					#
-- ##########################################################

-- ######################## TAGLIST #########################

-- Do not show the taglist squares (we use a different empty colour instead)
-- theme.taglist_squares_sel   = themes_path .. "nord/taglist/squarefz.png"
-- theme.taglist_squares_unsel = themes_path .. "nord/taglist/squarez.png"
local taglist_square_size = with_dpi(0)

-- taglist colours
theme.taglist_bg_focus = theme.nord3
theme.taglist_fg_focus = theme.nord13
theme.taglist_bg_occupied = theme.bg_normal
theme.taglist_fg_occupied = theme.nord14
theme.taglist_bg_empty = theme.bg_normal
theme.taglist_fg_empty = theme.nord3
theme.taglist_bg_urgent = theme.bg_normal
theme.taglist_fg_urgent = theme.nord11
theme.taglist_bg_volatile = transparent
theme.taglist_fg_volatile = theme.xcolor11

-- ####################### ICONS ############################

-- awesome icons
theme.awesome_icon           = themes_path .. "nord/awesome-icon.png"
theme.menu_submenu_icon      = themes_path .. "default/submenu.png"

-- layout icons
theme.layout_tile       = themes_path .. "nord/layouts/tile.png"
theme.layout_tileleft   = themes_path .. "nord/layouts/tileleft.png"
theme.layout_tilebottom = themes_path .. "nord/layouts/tilebottom.png"
theme.layout_tiletop    = themes_path .. "nord/layouts/tiletop.png"
theme.layout_fairv      = themes_path .. "nord/layouts/fairv.png"
theme.layout_fairh      = themes_path .. "nord/layouts/fairh.png"
theme.layout_spiral     = themes_path .. "nord/layouts/spiral.png"
theme.layout_dwindle    = themes_path .. "nord/layouts/dwindle.png"
theme.layout_max        = themes_path .. "nord/layouts/max.png"
theme.layout_fullscreen = themes_path .. "nord/layouts/fullscreen.png"
theme.layout_magnifier  = themes_path .. "nord/layouts/magnifier.png"
theme.layout_floating   = themes_path .. "nord/layouts/floating.png"
theme.layout_cornernw   = themes_path .. "nord/layouts/cornernw.png"
theme.layout_cornerne   = themes_path .. "nord/layouts/cornerne.png"
theme.layout_cornersw   = themes_path .. "nord/layouts/cornersw.png"
theme.layout_cornerse   = themes_path .. "nord/layouts/cornerse.png"

-- -- {{{ batteryarc_widget
-- theme.widget_main_color = "#88C0D0"
-- theme.widget_red = "#BF616A"
-- theme.widget_yellow = "#EBCB8B"
-- theme.widget_green = "#A3BE8C"
-- theme.widget_black = "#000000"
-- theme.widget_transparent = "#00000000"

-- ################# WIDGET CONTAINERS ######################

-- keyboard widget colours
theme.keyboard_fg = theme.nord0
theme.keyboard_bg = theme.nord12

-- battery widget color
theme.battery_fg = theme.fg_normal
theme.battery_bg = theme.bg_normal

-- volume widget colors
theme.volume_fg = theme.nord0
theme.volume_bg = theme.nord13

-- network widget colour
theme.network_fg = theme.nord4
theme.network_bg = theme.bg_normal

-- #################### WIDGET ICONS ########################

local path_to_icons = "/usr/share/icons/Papirus/symbolic/"
-- Each icon is on the form:
-- 		icon_name = {relative_svg_image_path, icon_colour}
local icon_arr = {
	-- Volume icons
	volume_low    = {"status/audio-volume-low-symbolic.svg", theme.volume_fg},
	volume_medium = {"status/audio-volume-medium-symbolic.svg", theme.volume_fg},
	volume_high   = {"status/audio-volume-high-symbolic.svg", theme.volume_fg},
	volume_muted  = {"status/audio-volume-muted-symbolic.svg", theme.volume_fg},

	-- Keyboard layout icon
	keyboard      = {"devices/input-keyboard-symbolic.svg", theme.keyboard_fg},

	-- Battery icons
	battery_empty_charging = {"status/battery-empty-charging-symbolic.svg", theme.battery_fg},
	battery_empty = {"status/battery-empty-symbolic.svg", theme.battery_fg},
	battery_caution_charging = {"status/battery-caution-charging-symbolic.svg", theme.battery_fg},
	battery_caution = {"status/battery-caution-symbolic.svg", theme.battery_fg},
	battery_low_charging = {"status/battery-low-charging-symbolic.svg", theme.battery_fg},
	battery_low = {"status/battery-low-symbolic.svg", theme.battery_fg},
	battery_medium_charging = {"status/battery-medium-charging-symbolic.svg", theme.battery_fg},
	battery_medium = {"status/battery-medium-symbolic.svg", theme.battery_fg},
	battery_good_charging = {"status/battery-good-charging-symbolic.svg", theme.battery_fg},
	battery_good = {"status/battery-good-symbolic.svg", theme.battery_fg},
	battery_full_charging = {"status/battery-full-charging-symbolic.svg", theme.battery_fg},
	battery_full = {"status/battery-full-symbolic.svg", theme.battery_fg},

	-- Network icons
	-- TODO: add these to the wireless module thingy
	wired_connected  = {"status/network-wired-symbolic.svg", theme.network_fg},
	vpn_connected	 = {"status/network-vpn-symbolic.svg", theme.network_fg},
	signal_none      = {"status/network-wireless-signal-none-symbolic.svg", theme.network_fg},
	signal_weak      = {"status/network-wireless-signal-weak-symbolic.svg", theme.network_fg},
	signal_good      = {"status/network-wireless-signal-good-symbolic.svg", theme.network_fg},
	signal_excellent = {"status/network-wireless-signal-excellent-symbolic.svg", theme.network_fg}
}

-- colour the icons and then store them
theme.icon = {}
for k, v in pairs(icon_arr) do
	theme.icon[k] = gears.color.recolor_image(path_to_icons .. v[1], v[2])
end

-- ######################## CALENDAR ########################

theme.calendar_styling = {
	long_weekdays = true,
	margin = theme.gap,
	-- holistic calendar styling
	style_month = {
		bg_color = theme.bg_normal,
		border_width = 0,
		fg_color = theme.fg_normal,
		padding = 14
	},
	style_header = {
		border_width = 0
	},
	style_weekday = {
		border_width = 0
	},
	style_normal = {
		border_width = 0,
		fg_color = theme.nord14
	},
	style_focus = {
		border_width = 0,
		fg_color = theme.nord13,
		bg_color = theme.nord3
	},
	font = theme.font
}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
