local beautiful = require("beautiful")
local wibox     = require("wibox")

local function compose_widget(left_icon_widget, right_text_widget, fg, bg)
	left_icon_widget.forced_width = 20
	return wibox.widget {
		wibox.widget {
			-- icon container
			wibox.widget {
				left_icon_widget,
				widget = wibox.container.place,
				halign = "right",
				forced_width = 35
			},
			-- text container
			wibox.widget {
				right_text_widget,
				halign = "left",
				widget = wibox.container.place,
				forced_width = 45
			},
			layout = wibox.layout.fixed.horizontal
		},
		widget = wibox.container.background,
		bg = bg,
		fg = fg
	}
end

local wibarutil = {
	compose_widget = compose_widget
}

return wibarutil
