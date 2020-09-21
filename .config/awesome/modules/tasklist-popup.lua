local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local function get_popup_arg(s)
	return {
		widget = awful.widget.tasklist {
			screen   = s,
			filter   = awful.widget.tasklist.filter.currenttags,
			buttons  = tasklist_buttons,
			style    = {
				shape = gears.shape.rounded_rect,
			},
			layout   = {
				spacing = 5,
				forced_num_rows = 1,
				layout = wibox.layout.grid.horizontal }, widget_template = {
					{
						{
							id     = 'clienticon',
							widget = awful.widget.clienticon,
						},
						margins = 4,
						widget  = wibox.container.margin,
					},
					id              = 'background_role',
					forced_width    = 48,
					forced_height   = 48,
					widget          = wibox.container.background,
					create_callback = function(self, c, index, objects) --luacheck: no unused
						self:get_children_by_id('clienticon')[1].client = c
					end,
				},
			},
			ontop        = true,
			placement    = awful.placement.centered,
			shape        = gears.shape.rounded_rect,
			screen 		 = s,
			visible 	 = false
		}
	end

local Class = {}
return setmetatable(Class, {
	__call = function(_, ...) return get_popup_arg(...) end
})
