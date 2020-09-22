local awful = require("awful")
local naughty = require("naughty")

timers = { 5,10 }
screenshot = os.getenv("HOME") .. "/Pictures/screenshots/$(date +%F_%T).png"

local function _cmd(cmd)
    -- awful.util.spawn_with_shell(cmd)
    awful.util.spawn_with_shell(cmd)
end

local function _show_msg(text)
	awful.spawn.easy_async("sleep 0.2", function () 
		naughty.notify({
			text = text,
			timeout = 2
		})
	end)
end

function screenshot_full()
	_cmd("gnome-screenshot -f " .. screenshot)
	_show_msg("Taking a screenshot of the entire screen")
end

function screenshot_selection()
	-- often fails, so call it 10 times lmao
	for i = 1, 10 do
		_cmd("gnome-screenshot -f " .. screenshot .. " -a")
	end
	_show_msg("Taking a screenshot of selected area")
end

function screenshot_selection_clipboard()
	-- often fails, so call it 10 times lmao
	for i = 1, 10 do
		_cmd("gnome-screenshot -af /tmp/screenshot-image && cat /tmp/screenshot-image | xclip -i -selection clipboard -target image/png")
	end
	_show_msg("Taking a screenshot of selected area to clipboard")
end

-- function screenshot_window()
-- 	_cmd("gnome-screenshot -f " .. screenshot .. " -w")
-- 	_show_msg("Taking a screenshot of current window")
-- end

function screenshot_delay()
    items={}
    for key, value in ipairs(timers)  do
        items[#items+1]={tostring(value) , "gnome-screenshot -c -d " .. value}
    end
    awful.menu.new(
    {
        items = items
    }
    ):show({keygrabber= true})
end

