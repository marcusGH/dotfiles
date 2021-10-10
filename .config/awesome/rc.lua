

-- ##########################################################
-- #                     	IMPORTS						 	#
-- ##########################################################

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local with_dpi = require('beautiful').xresources.apply_dpi
local get_dpi = require('beautiful').xresources.get_dpi
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Screenshot utility
local screenshot = require("modules.screenshot")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- -- Load Debian menu entries
-- local debian = require("debian.menu")
-- local has_fdo, freedesktop = pcall(require, "freedesktop")

-- ##########################################################
-- #                     ERROR HANDLING						#
-- ##########################################################

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)

-- ##########################################################
-- #                VARIABLE DEFINITIONS					#
-- ##########################################################

-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(awful.util.get_configuration_dir() .. "themes/nord/theme.lua")

-- location of user directory
user_dir = "/home/marcus/"

-- This is used as the default terminal and editor to run.
terminal = "x-terminal-emulator --hide-menubar"
-- Default text editor
editor = awful.util.get_configuration_dir() .. "delayLaunch.sh vim"
editor_cmd = terminal .. " -e " .. editor
-- Rofi launcher command
rofi_command = 'env /usr/bin/rofi -dpi ' .. get_dpi() .. ' -width ' ..
                         with_dpi(400) .. ' -show drun -theme ' ..
                         '~/.config/rofi/nord.rasi -run-command ' ..
						 '"/bin/bash -c -i \'shopt -s expand_aliases; {cmd}\'"'
firefox_command = "env firefox"
vim_command     = editor_cmd
nautilus_command= "nautilus /home/marcus"
i3lock_command  = awful.util.get_configuration_dir() .. "i3lock-fancy-multimonitor/lock -b=0x8 -n"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        -- awful.layout.suit.tile.top,
        -- awful.layout.suit.fair,
        -- awful.layout.suit.fair.horizontal,
        -- awful.layout.suit.spiral,
        -- awful.layout.suit.spiral.dwindle,
        -- awful.layout.suit.max,
        -- awful.layout.suit.max.fullscreen,
        -- awful.layout.suit.magnifier,
        -- awful.layout.suit.corner.nw,
    })
end)

-- set the wallpaper
screen.connect_signal("request::wallpaper", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s)
    end
end)

-- ##########################################################
-- #				AWESOME MENU AND CONFIG MENU  			#
-- ##########################################################

-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = {
	{ "awesome", myawesomemenu, beautiful.awesome_icon },
	{ "open terminal", terminal }
}})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- configuration menu for quickly accessing configuration files
local my_configs = {
	vim = user_dir .. ".vimrc",
    awesome_th = awful.util.get_configuration_dir() .. "themes/nord/theme.lua",
	awesome_rc = awful.util.get_configuration_dir() .. "rc.lua",
    latex = user_dir .. "maks2/.latex/supo.sty",
    latex_snip = user_dir .. ".vim/snippets/tex.snippets",
    rofi = user_dir .. ".config/rofi/nord.rasi",
    monitor = awful.util.get_configuration_dir() .. "monitor-fix.sh",
    bashprofile = user_dir .. ".bash_profile"
}
local my_config_arr = {}
for k, v in pairs(my_configs) do
	table.insert(my_config_arr, {k, editor_cmd .. " " .. v})
end
my_config_menu = awful.menu({ items = my_config_arr })

-- ##########################################################
-- # 				MENU BAR AND WIDGETS					#
-- ##########################################################

-- Set the terminal for applications that require it
menubar.utils.terminal = terminal 

local battery_widget = require("modules.battery")
local volume_control = require("modules.volume-control")
local volumecfg = volume_control({
	font = beautiful.font,
	device="pulse"
})
local network_widget = require("modules.network")

-- Keyboard map indicator and switcher
local mykeyboardlayout = require("modules.keyboard")

-- Create a textclock widget and attach a calendar to it
local mytextclock = wibox.widget {
	halign = "center",
	widget = wibox.container.place,
	wibox.widget.textclock(	-- refresh every 60 seconds
		string.format("<span><b>%%H:%%M</b></span>"), 60),
	-- matches the calendar popup's size (?)
	forced_width = 233
}

local month_calendar = awful.widget.calendar_popup.month(beautiful.calendar_styling)

mytextclock:connect_signal("mouse::enter", function()
    month_calendar:call_calendar(0, "tm", awful.screen.focused())
    month_calendar.visible = true
end)
mytextclock:connect_signal("mouse::leave", function()
    month_calendar.visible = false
end)
mytextclock:buttons(gears.table.join(
    awful.button({ }, 1, function() month_calendar:call_calendar(-1) end),
    awful.button({ }, 3, function() month_calendar:call_calendar( 1) end)
))

-- tag definitions
screen.connect_signal("request::desktop_decoration", function(s)
	-- This alias saves some typing
	local l = awful.layout.suit
    -- primary tag (start here)
    awful.tag.add(" PRM ", {
        selected = true,
        layout = l.tile,
        screen = s,
    })
	-- main tag (start at this one)
	awful.tag.add(" TWO ", {
		layout = l.tile.bottom,
        master_width_factor = 0.85,
        column_count = 3,
        master_count = 2,
		gap = 0,
		screen = s,
	})
	-- latex tag (vim + zathura)
	awful.tag.add(" LTX ", {
		layout = l.tile,
		gap = 5,
        master_width_factor = 0.5,
        column_count = 1, -- change to 2 on large monitor
        master_count = 1,
		screen = s,
	})
    -- dev tag (development in e.g. jetbrain IDEs)
    awful.tag.add(" DEV ", {
        layout = l.tile.left,
        gap_single_client = false,
        master_width_factor = 0.6,
        master_count = 1,
        gap = 0,
        screen = s,
    })
	-- chat tag (e.g. discord)
	awful.tag.add(" CHT ", {
		layout = l.tile.left,
        gap_single_client = false,
        master_width_factor = 0.7,
        master_count = 1,
        gap = 0,
		screen = s
	})
	-- float tag (???)
	awful.tag.add(" FLT ", {
		layout = l.floating,
		screen = s,
	})
    -- www tag (internet browsing)
    awful.tag.add(" WEB ", {
        layout = l.max.fullscreen,
        screen = s
    })
    -- Each screen has its own tag table.
    -- awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        }
    }

	-- Create a custom tab-cycle menu (mod4+tab)
	local popup_arg_table = require("modules.tasklist-popup")
	s.myappswitcher = awful.popup (popup_arg_table(s))

	-- We need access to the clock later to change its colours
	s.myclockwidget = wibox.widget {
		fg = beautiful.clock_fg_normal,
		bg = beautiful.clock_bg_normal,
		mytextclock,
		layout = wibox.container.background
	}
	
    -- Create the menubar wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 30 })

    -- Add widgets to the menubar wibox
    s.mywibox.widget = {
        layout = wibox.layout.align.horizontal,
 		-- makes the middle widget centred
		expand = "none",
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- mylauncher,	-- we use rofi instead
            s.mytaglist,
            s.mypromptbox,
        },
		 -- Middle widgets
        s.myclockwidget,
		-- s.mytasklist
        { -- Right widgets
            wibox.widget.systray(),
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout, 			
			battery_widget,				
			volumecfg.composite_widget, 
			network_widget,				
            s.mylayoutbox
        },
    }
end)

-- ##########################################################
-- # 			  MOUSE AND KEYBOARD BINDINGS				#
-- ##########################################################

-- Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext),
})

-- Key(board) bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
	-- Reason for comment: Replaced by rofi launcher
    -- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --           {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
})

-- Client focus related keybindings
require("awesomewm-vim-tmux-navigator"){
	up    = {"k"},
	down  = {"j"},
	left  = {"h"},
	right = {"l"}
}

-- Reason for comment: These are handled above
-- -- Focus related keybindings
-- awful.keyboard.append_global_keybindings({
--     awful.key({ modkey,           }, "j",
--         function ()
--             awful.client.focus.byidx( 1)
--         end,
--         {description = "focus next by index", group = "client"}
--     ),
--     awful.key({ modkey,           }, "k",
--         function ()
--             awful.client.focus.byidx(-1)
--         end,
--         {description = "focus previous by index", group = "client"}
--     ),

-- More client related keybindings
awful.keyboard.append_global_keybindings({
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_bydirection("left") end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_bydirection("right") end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey, "Control" }, "n",
		function ()
			local c = awful.client.restore()
			-- Focus restored client
			if c then
				c:activate { raise = true, context = "key.unminimize" }
			end
		end,
    {description = "restore minimized", group = "client"})
})

-- Client cycling (Mod4+Tab) and reverse order by holding down "Shift"
awful.keygrabber {
    keybindings = {
        {{modkey    }, 'Tab', function() awful.client.focus.byidx(1) end,
			{description = "cycle through clients", group = "client"}},
        {{modkey, "Shift"}, 'Tab', function() awful.client.focus.byidx(-1) end,
			{description = "cycle through clients", group = "client"}}
    },
    stop_key       = modkey,
	stop_event     = "release",
	start_callback = function()
		awful.screen.focused().myappswitcher.visible = true
		end,
	stop_callback  = function()
		awful.screen.focused().myappswitcher.visible = false
		end,
	export_keybindings = true,
}

-- Custom keybindings
awful.keyboard.append_global_keybindings({
	-- Prompt (run rofi)
	awful.key({ modkey },			 "r", 	  function () awesome.spawn(rofi_command) end,
		{description = "run rofi prompt", group = "launcher"}),
	-- Open the browser
	awful.key({ modkey },			 "b",	  function () awesome.spawn(firefox_command) end,
		{description = "run firefox", group = "launcher"}),
    -- Open vim
    awful.key({ modkey },            "v",     function() awful.util.spawn_with_shell(editor_cmd) end,
        {description = "run vim",     group = "launcher"}),
    -- Open nautilus
    awful.key({ modkey },            "e",     function() awful.util.spawn(nautilus_command) end,
        {description = "open file manager", group="launcher"}),
	-- Open config menu
	awful.key({ modkey },			 "c",	  function () my_config_menu:show() end,
		{description = "show config menu", group = "launcher"}),
	-- Audio controls
	awful.key( {}, 'XF86AudioRaiseVolume', 	  function() volumecfg:up() end,
		{description = 'volume up', group = 'hotkeys'}),
	awful.key( {}, 'XF86AudioLowerVolume',    function() volumecfg:down() end,
		{description = 'volume down', group = 'hotkeys'}),
	awful.key( {}, 'XF86AudioMute',           function() volumecfg:toggle() end,
		{description = 'toggle mute', group = 'hotkeys'}),
	-- Screenshots
	awful.key({ }, "Print", screenshot_full,
		{description = "Take a screenshot of entire screen", group = "hotkeys"}),
	awful.key({ "Shift", }, "Print", screenshot_selection,
		{description = "Take a screenshot of selection", group = "hotkeys"}),
	awful.key({ "Shift", "Ctrl"}, "Print", screenshot_selection_clipboard,
		{description = "Take a screenshot of selection to clipboard", group = "hotkeys"}),
	awful.key({ "Ctrl" }, "Print", screenshot_delay,
		{description = "Take a screenshot with a delay to clipboard", group = "hotkeys"}),
	-- i3 lockscreen
	awful.key({ modkey },		   "q",    function () awful.util.spawn(i3lock_command) end,
		{description = "lock the screen", group="hotkeys"})
    -- awful.key({ modkey, "Shift"}, "w", function () mykeyboardlayout:next_layout() end,
    --     {description = "Select the next keyboard layout", group = "hotkeys"})
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift"   }, ".",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, ",",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, "Right",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey,           }, "Left",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey,           }, "Up",       function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "Down",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
})

-- Tag related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift"   }, "h"  ,    awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "l"   ,   awful.tag.viewnext,
              {description = "view next",     group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back",       group = "tag"}),
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

-- Mouse bindings to resize floating windows
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

-- Client related keybindings
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
                {description = "close", group = "client"}),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
        awful.key({ modkey,           }, "o",      function (c) c:move_to_screen(c.screen.get_next_in_direction(c.screen, "right").index)               end,
                {description = "move to screen", group = "client"}),
        awful.key({ modkey, "Shift"   }, "o",      function (c) c:move_to_screen(c.screen.get_next_in_direction(c.screen, "left").index)               end,
                {description = "move from screen", group = "client"}),
        awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
                {description = "toggle keep on top", group = "client"}),
        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, "Control" }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, "Shift"   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)

-- ##########################################################
-- #                     	RULES 							#
-- ##########################################################

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
			-- force clients (mostly terminals) to get the correct sizes
			size_hints_honor = false
        }, callback = function(c)
            -- spawn new clients in DEV and in TRM as slaves
            if (c.first_tag.name == " DEV " or
                c.first_tag.name == " LTX " or
                c.first_tag.name == " CHT " or
                c.first_tag.name == " TRM ") then
                awful.client.setslave(c)
            end
    end
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        id         = "titlebars",
        rule_any   = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true      }
    }

	-- TODO: add firefox to WEB
    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)

-- Reason for commenting out: I don't want titlebars
-- ##########################################################
-- #                    TITLE BARS 							#
-- ##########################################################
-- -- Add a titlebar if titlebars_enabled is set to true in the rules.
-- client.connect_signal("request::titlebars", function(c)
--     -- buttons for the titlebar
--     local buttons = {
--         awful.button({ }, 1, function()
--             c:activate { context = "titlebar", action = "mouse_move"  }
--         end),
--         awful.button({ }, 3, function()
--             c:activate { context = "titlebar", action = "mouse_resize"}
--         end),
--     }
--
--     awful.titlebar(c).widget = {
--         { -- Left
--             awful.titlebar.widget.iconwidget(c),
--             buttons = buttons,
--             layout  = wibox.layout.fixed.horizontal
--         },
--         { -- Middle
--             { -- Title
--                 align  = "center",
--                 widget = awful.titlebar.widget.titlewidget(c)
--             },
--             buttons = buttons,
--             layout  = wibox.layout.flex.horizontal
--         },
--         { -- Right
--             awful.titlebar.widget.floatingbutton (c),
--             awful.titlebar.widget.maximizedbutton(c),
--             awful.titlebar.widget.stickybutton   (c),
--             awful.titlebar.widget.ontopbutton    (c),
--             awful.titlebar.widget.closebutton    (c),
--             layout = wibox.layout.fixed.horizontal()
--         },
--         layout = wibox.layout.align.horizontal
--     }
-- end)

-- disable borders for maximised and alone clients
screen.connect_signal("arrange", function (s)
    local max = s.selected_tag.layout.name == "max"
	-- use tiled_clients so that other floating windows don't affect the count
    local only_one = #s.tiled_clients == 1
    -- but iterate over clients instead of tiled_clients as tiled_clients doesn't include maximized windows
    for _, c in pairs(s.clients) do
        if (max or only_one) and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)

-- ##########################################################
-- #                     MISCELLANEOUS  					#
-- ##########################################################

-- Colour the clock widget on the focused screen
client.connect_signal("focus", function(c)
	-- revert to default
	for s in screen do
		s.myclockwidget.bg = beautiful.clock_bg_normal
		s.myclockwidget.fg = beautiful.clock_fg_normal
	end
	-- set the colours for the screen with the focused client
	c.screen.myclockwidget.bg = beautiful.clock_bg_focus
	c.screen.myclockwidget.fg = beautiful.clock_fg_focus
end)


-- Notification rules
ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)

-- Reason for commenting out: sloppy focus is annoying
-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:activate { context = "mouse_enter", raise = false }
-- end)

-- Auto-run programs script
awful.spawn.with_shell(awful.util.get_configuration_dir() .. "autorun.sh")
-- Fix multiple monitors
awful.spawn.with_shell(awful.util.get_configuration_dir() .. "monitor-fix.sh")
-- Turn off screen lock
awful.spawn.with_shell("xset s off")
