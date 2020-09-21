-- Volume Control
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

-- compatibility fallbacks for 3.5:
local timer = gears.timer or timer
local spawn = awful.spawn or awful.util.spawn
local watch = awful.spawn and awful.spawn.with_line_callback
local wibarutil = require("wibarutil")

local path_to_icons = "/usr/share/icons/Papirus-Dark/"

------------------------------------------
-- Private utility functions
------------------------------------------

-- local function readcommand(command)
-- 	awful.spawn.easy_async(command, function(out)
-- 		text = out)
--     local file = io.popen(command)
--     local text = file:read('*all')
--     file:close()
--     return text
-- end

local function quote_arg(str)
    return "'" .. string.gsub(str, "'", "'\\''") .. "'"
end

local function table_map(func, tab)
    local result = {}
    for i, v in ipairs(tab) do
        result[i] = func(v)
    end
    return result
end

local function make_argv(args)
    return table.concat(table_map(quote_arg, args), " ")
end

local function substitute(template, context)
  if type(template) == "string" then
    return (template:gsub("%${([%w_]+)}", function(key)
      return tostring(context[key] or "default")
    end))
  else
    -- function / functor:
    return template(context)
  end
end

local function new(self, ...)
    local instance = setmetatable({}, {__index = self})
    return instance:init(...) or instance
end

local function class(base)
    return setmetatable({new = new}, {
        __call = new,
        __index = base,
    })
end

------------------------------------------
-- Volume control interface
------------------------------------------

local vcontrol = class()

function vcontrol:init(args)
    self.callbacks = {}
    self.cmd = "amixer"
    self.device = args.device or nil
    self.cardid  = args.cardid or nil
    self.channel = args.channel or "Master"
    self.step = args.step or '5%'

    self.timer = timer({ timeout = args.timeout or 0.5 })
    self.timer:connect_signal("timeout", function() self:get() end)
    self.timer:start()

    if args.listen and watch then
        self.listener = watch({'stdbuf', '-oL', 'alsactl', 'monitor'}, {
          stdout = function(line) self:get() end,
        })
        awesome.connect_signal("exit", function()
            awesome.kill(self.listener, awesome.unix_signal.SIGTERM)
        end)
    end
end

function vcontrol:register(callback)
    if callback then
        table.insert(self.callbacks, callback)
    end
end

function vcontrol:action(action)
    if self[action]                   then self[action](self)
    elseif type(action) == "function" then action(self)
    elseif type(action) == "string"   then spawn(action)
    end
end

function vcontrol:update(status)
    local volume = status:match("(%d?%d?%d)%%")
    local state  = status:match("%[(o[nf]*)%]")
    if volume and state then
        local volume = tonumber(volume)
        local state = state:lower()
        local muted = state == "off"
        for _, callback in ipairs(self.callbacks) do
            callback(self, {
                volume = volume,
                state = state,
                muted = muted,
                on = not muted,
            })
        end
    end
end

function vcontrol:mixercommand(...)
    local args = awful.util.table.join(
      {self.cmd},
      (self.cmd == "amixer") and {"-M"} or {},
      self.device and {"-D", self.device} or {},
      self.cardid and {"-c", self.cardid} or {},
      {...})
	awful.spawn.easy_async(table.concat(args, " "), function(out)
		self:update(out)
	end)
    -- return readcommand(make_argv(args))
end

function vcontrol:get()
    -- self:update(self:mixercommand("get", self.channel))
    self:mixercommand("get", self.channel)
end

function vcontrol:up()
    -- self:update(self:mixercommand("set", self.channel, self.step .. "+"))
    self:mixercommand("set", self.channel, self.step .. "+")
end

function vcontrol:down()
    -- self:update(self:mixercommand("set", self.channel, self.step .. "-"))
    self:mixercommand("set", self.channel, self.step .. "-")
end

function vcontrol:toggle()
    -- self:update(self:mixercommand("set", self.channel, "toggle"))
    self:mixercommand("set", self.channel, "toggle")
end

function vcontrol:mute()
    -- self:update(self:mixercommand("set", "Master", "mute"))
    self:mixercommand("set", "Master", "mute")
end

function vcontrol:unmute()
    -- self:update(self:mixercommand("set", "Master", "unmute"))
    self:mixercommand("set", "Master", "unmute")
end

function vcontrol:list_sinks()
    local sinks = {}
    local sink
    for line in io.popen("env LC_ALL=C pactl list sinks"):lines() do
        if line:match("Sink #%d+") then
            sink = {}
            table.insert(sinks, sink)
        else
            local k, v = line:match("^%s*(%S+):%s*(.-)%s*$")
            if k and v then sink[k:lower()] = v end
        end
    end
    return sinks
end

function vcontrol:set_default_sink(name)
	awful.spawn('pactl set-default-sink ' .. name)
end

------------------------------------------
-- Volume control widget
------------------------------------------

-- derive so that users can still call up/down/mute etc
local vwidget = class(vcontrol)

function vwidget:init(args)

    vcontrol.init(self, args)

    self.lclick = args.lclick or "toggle"
    self.mclick = args.mclick or "pavucontrol"
    self.rclick = args.rclick or self.show_menu

    self.font        = args.font    or nil
    self.text_widget = (self:create_text_widget(args)  or self.text_widget)
	self.icon_widget = (self:create_icon_widget(args) or self.icon_widget)
    self.tooltip     = args.tooltip and (self:create_tooltip(args) or self.tooltip)

	self.composite_widget = wibarutil.compose_widget(self.icon_widget,
		self.text_widget, beautiful.volume_fg, beautiful.volume_bg)

    self:register(args.callback or self.update_widget)
    self:register(args.tooltip and self.update_tooltip)

    self.composite_widget:buttons(awful.util.table.join(
        awful.button({}, 1, function() self:action(self.lclick) end),
        awful.button({}, 2, function() self:action(self.mclick) end),
        awful.button({}, 3, function() self:action(self.rclick) end),
        awful.button({}, 4, function() self:up() end),
        awful.button({}, 5, function() self:down() end)
    ))

    self:get()
end

-- icon widget
function vwidget:create_icon_widget(args)
	-- TODO: this
	self.icon_widget = wibox.widget {
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			resize = false
		},
		layout = wibox.container.margin(_, 0, 0, -1)
	}
end

-- text widget
function vwidget:create_text_widget(args)
    self.widget_text = args.widget_text or {
        on  = '% 3d%% ',
        off = '% 3dM ',
    }
    self.text_widget = wibox.widget.textbox()
    if self.font then
      self.text_widget.font = self.font
    end
    self.text_widget.set_align("right")
end

function vwidget:create_menu()
    local sinks = {}
    for i, sink in ipairs(self:list_sinks()) do
        table.insert(sinks, {sink.description, function()
			naughty.notification({ title = sink.name })
            self:set_default_sink(sink.name)
        end})
    end
    return awful.menu { items = {
        { "mute", function() self:mute() end },
        { "unmute", function() self:unmute() end },
        { "Default Sink", sinks },
        { "pavucontrol", function() self:action("pavucontrol") end },
    } }
end

function vwidget:show_menu()
    if self.menu then
        self.menu:hide()
    else
        self.menu = self:create_menu()
        self.menu:show()
        self.menu.wibox:connect_signal("property::visible", function()
            self.menu = nil
        end)
    end
end

function vwidget:update_widget(setting)
    self.text_widget:set_markup(
        self.widget_text[setting.state]:format(setting.volume))
	
	-- set the image icons
	if setting.muted then
		self.icon_widget.icon:set_image(beautiful.icon.volume_muted)
	elseif setting.volume < 33 then
		self.icon_widget.icon:set_image(beautiful.icon.volume_low)
	elseif setting.volume < 67 then
		self.icon_widget.icon:set_image(beautiful.icon.volume_medium)
	else
		self.icon_widget.icon:set_image(beautiful.icon.volume_high)
	end
end

-- tooltip
function vwidget:create_tooltip(args)
    self.tooltip_text = args.tooltip_text or [[
Volume: ${volume}% ${state}
Channel: ${channel}
Device: ${device}
Card: ${card}]]
    self.tooltip = args.tooltip and awful.tooltip({objects={self.text_widget}})
end

function vwidget:update_tooltip(setting)
    self.tooltip:set_text(substitute(self.tooltip_text, {
        volume  = setting.volume,
        state   = setting.state,
        device  = self.device,
        card    = self.card,
        channel = self.channel,
    }))
end

-- provide direct access to the control class
vwidget.control = vcontrol
return vwidget
