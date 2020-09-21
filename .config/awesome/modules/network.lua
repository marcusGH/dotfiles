local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local gears         = require("gears")
local cairo         = require("lgi").cairo
local module_path = (...):match ("(.+/)[^/]+$") or ""
local wibarutil 	= require("wibarutil")

local theme = beautiful.get()

function dbg(message)
	naughty.notify({ preset = naughty.config.presets.normal,
	title = "debug",
	text = message })
end

local function draw_signal(level)
	local signal_strength = ""
	if level > 67 then
		signal_strength  = "excellent"
	elseif level > 33 then
		signal_strength  = "good"
	elseif level > 0 then
		signal_strength  = "weak"
	else
		signal_strength  = "none"
	end

	return beautiful.icon["signal_" .. signal_strength]
	
	-- draw 32x32 for simplicity, imagebox will resize it using loseless transform
	-- local img = cairo.ImageSurface.create(cairo.Format.ARGB32, 32, 32)
	-- local cr  = cairo.Context(img)
    --
	-- cr:set_source(gears.color(theme.fg_normal))
	-- if level > 75 then
	-- 	cr:arc(         32/2, 32/2, 32/2, 145*math.pi/180, 395*math.pi/180)
	-- 	cr:arc_negative(32/2, 32/2, 32/2-3, 395*math.pi/180, 145*math.pi/180)
	-- end
	-- if level > 50 then
	-- 	cr:arc(         32/2, 32/2, 24/2, 145*math.pi/180, 395*math.pi/180)
	-- 	cr:arc_negative(32/2, 32/2, 24/2-3, 395*math.pi/180, 145*math.pi/180)
	-- end
	-- if level > 25 then
	-- 	cr:arc(         32/2, 32/2, 16/2, 145*math.pi/180, 395*math.pi/180)
	-- 	cr:arc_negative(32/2, 32/2, 16/2-3, 395*math.pi/180, 145*math.pi/180)
	-- end
	-- cr:rectangle(32/2-1, 32/2-1, 2, 32/2-2)
	-- cr:fill()
    --
	-- if level == 0 then
	-- 	cr:set_source(gears.color("#cf5050"))
	-- 	gears.shape.transform(gears.shape.cross)
	-- 	:rotate(45*math.pi/180)
	-- 	:translate(12, -10)(cr, 10, 10, 3)
	-- end
    --
	-- cr:close_path()
	-- cr:fill()
	-- return img
end


local wireless = {}
local function worker(args)
	local args = args or {}

	widgets_table = {}
	local connected = false

	-- Wireless icon settings
	local ICON_DIR      = awful.util.getdir("config").."/"..module_path.."/net_widgets/icons/"
	local interface     = args.interface or "wlan0"
	local timeout       = args.timeout or 5
	local font          = args.font or beautiful.font
	local popup_signal  = args.popup_signal or false
	local popup_position = args.popup_position or naughty.config.defaults.position
	local onclick       = args.onclick
	local widget        = args.widget == nil and wibox.layout.fixed.horizontal() or args.widget == false and nil or args.widget
	local indent        = args.indent or 3
	-- Wired indicator settings
	local interfaces = args.interfaces
	local ignore_interfaces = args.ignore_interfaces or {}
	local timeout = args.timeout or 10
	local font = args.font or beautiful.font
	local onclick = args.onclick
	local hidedisconnected = args.hidedisconnected
	local popup_position = args.popup_position or naughty.config.defaults.position

	-- Turn off advanced details by default
	if args.skiproutes == nil then
		args.skiproutes = true
	end
	if args.skipcmdline == nil then
		args.skipcmdline = true
	end
	if args.skipvpncheck == nil or args.skiproutes or args.skipcmdline then
		args.skipvpncheck = true
	end

	local real_interfaces = nil
	-----------------------
	-- This function fetches the latest info about a given interface
	-- It makes use of `io.popen` so we only run it asynchronously
	-- It updates the global variable `real_interfaces`
	-- It only processes the interfaces listed in the `interfaces` argument
	-- If that argument is blank it will process all interfaces
	-----------------------
	local function get_interfaces()
		----
		-- First, get the `links` table of all link data for relevant interfaces
		----
		local links = {}
		-- All on one line:
		-- 2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel
		--    state UP mode DEFAULT group default qlen 1000\ link/ether
		--    1c:6f:65:3f:48:9a brd ff:ff:ff:ff:ff:ff
		-- 32: br-39d5fbb21742: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc
		--    noqueue state DOWN mode DEFAULT group default \    link/ether
		--    02:42:68:08:88:34 brd ff:ff:ff:ff:ff:ff
		local ipl_pattern = "^%d+:%s+([^%s]+):%s+<.*>%s.*%s" ..
		"state%s+([^%s]+)%s.*%slink/([^%s]+)[%s]*([%x:]*)"
		local f = io.popen("ip -oneline link show")
		for line in f:lines() do
			local iface, state, type_, mac = string.match(line, ipl_pattern)
			if not iface then
				notification = naughty.notify({
					preset = fs_notification_preset,
					text = "LINE: \n" .. line,
					timeout = t_out,
					screen = mouse.screen,
					position = popup_position
				})
				goto continue_iplink
			end

			for _, i in pairs(ignore_interfaces) do
				if (i == iface) then
					goto continue_iplink  -- ignore this interface
				end
			end
			if interfaces then
				for _, i in pairs(interfaces) do
					if (i == iface) then
						goto donotignore_iplink  -- do not ignore this link
					end
				end
				goto continue_iplink  -- ignore this link
			end
			::donotignore_iplink::  -- IS in the list of interfaces to process

			links[iface] = {iface = iface, state = state, type_ = type_, mac = mac}
			::continue_iplink::  -- is NOT in the list of interfaces to process
		end
		f:close()

		----
		-- Next, get the `ifaces` to be a sequence of tables with data about each
		-- relevant interface
		----
		-- TODO document all the fields in each `links[iface]` table
		local ifaces = {}

		-- Grab address information
		-- All on one line:
		-- 2: enp3s0    inet 192.168.1.190/24 brd 192.168.1.255 scope global \
		--    link/ether 1c:6f:65:3f:48:9a brd ff:ff:ff:ff:ff:ff
		local ipa_pattern = "^%d+:%s+([^%s]+)%s+([^%s]+)%s+([^%s]+)"
		local f = io.popen("ip -oneline addr show")
		for line in f:lines() do
			local iface, type_, addr = string.match(line, ipa_pattern)
			if not links[iface] then
				goto continue_ipaddr  -- is NOT in the list of interfaces to process
			end
			if not links[iface].addrs then
				-- First addr for this iface
				links[iface].addrs = {}
				table.insert(ifaces, links[iface])
			end
			table.insert(links[iface].addrs, {addr = addr, type_ = type_})
			::continue_ipaddr::  -- is NOT in the list of interfaces to process
		end
		f:close()

		-- Grab route information
		if (not args.skiproutes) then
			local f = io.popen("ip -oneline route show")
			for line in f:lines() do
				-- 10.11.0.0/24 dev tun2 proto kernel scope link src 10.11.0.3
				local rt, iface = string.match(line, "^([^%s]+)%s+dev%s+([^%s]+)")
				if rt then
					if not links[iface] then
						goto continue_iprts  -- is NOT in the list of interfaces to process
					end
					if not links[iface].localrts then  -- First route for this iface
						links[iface].localrts = {}
					end
					if string.match(line, " proto ") then
						proto = string.match(line, " proto ([^%s]+) ")
						if not (proto == "kernel") then  -- e.g., " proto dhcp "
							rt = rt .. " [" .. proto .. "]"
						end
					end
					table.insert(links[iface].localrts, rt)
				else
					-- 192.168.123.0/24 via 10.10.0.1 dev tun2
					rtpattern = "^([^%s]+%s+via%s+[^%s]+)%s+dev%s+([^%s]+)"
					rt, iface = string.match(line, rtpattern)
					if rt then
						if not links[iface] then
							goto continue_iprts  -- is NOT in the list of ifaces to process
						end
						if not links[iface].rts then  -- First route for this iface
							links[iface].rts = {}
							links[iface].coverage = {}
						end
						if string.match(line, " proto ") then
							proto = string.match(line, " proto ([^%s]+) ")
							if not (proto == "kernel") then  -- e.g., " proto dhcp "
								rt = rt .. " [" .. proto .. "]"
							end
						end
						table.insert(links[iface].rts, rt)
						if rt:match("^default") then
							rt = "0.0.0.0/0"
							--links[iface].default_route = true
						end
						local pattern = "^(%d+)%.(%d+)%.(%d+)%.(%d+)/(%d+)"
						local o1, o2, o3, o4, n = rt:match(pattern)
						if o1 and o2 and o3 and o4 and n then
							o1, o2, o3, o4, n = o1+0, o2+0, o3+0, o4+0, n+0
							if o1<256 and o2<256 and o3<256 and o4<256 and n<33 then
								local ipdec = 2^24*o1 + 2^16*o2 + 2^8*o3 + o4
								table.insert(links[iface].coverage, {ipdec, ipdec+2^(32-n)-1})
							end
						end
					else
						-- Regexps should catch every line!
						notification = naughty.notify({
							preset = fs_notification_preset,
							text = "Route pattern failure:\n" .. line,
							timeout = 300,
							screen = mouse.screen,
							position = popup_position
						})
					end
				end
				::continue_iprts::  -- is NOT in the list of interfaces to process
			end  -- for line in ip route
			f:close()

			-- TODO allow gaps in bogon space; check IPv6 coverage
			-- Label any iface with full route coverage as default_route
			for iface, s in pairs(links) do
				if s.coverage then
					s.default_route = true  -- iface is a default route, unless...
					table.sort(s.coverage, function (a, b) return a[1] < b[1] end)
					if s.coverage[1][1] > 0.0 then
						s.default_route = false  -- ...coverage starts at > 0...
					else
						local biggest = s.coverage[1][2]
						for i = 2, #s.coverage do
							if ((biggest+1) < s.coverage[i][1]) then
								s.default_route = false  -- ...or there's a gap...
								break
							end
							if s.coverage[i][2] > biggest then
								biggest = s.coverage[i][2]
							end
						end
						if biggest < ((2.0^32) - 1.0) then
							s.default_route = false  -- ...or coverage ends at < 2^32
						end
					end
				end
			end
		end  -- Grab route information

		-- Grab process information (e.g., for tun/tap devices)
		if (not args.skipcmdline) then
			local cmd = "sudo find /proc -name task -prune -o "
			cmd = cmd .. "-path /proc/\\*/fdinfo/\\* -print0 "
			cmd = cmd .. "| xargs -0 sudo grep '^iff:'"
			--cmd = cmd .. "| sed 's/^\\(.proc.*\\/\\)fdinfo.*/\\1cmdline/'"
			--cmd = cmd .. "| xargs grep -va asdfasdfasdf "
			--cmd = cmd .. "| sed 's/\\x00/ /g'"
			--cmd = cmd .. "\""
			local f = io.popen(cmd)
			for line in f:lines() do
				-- /proc/2993045/fdinfo/4:iff:     tun0
				iff_pattern = "^/proc/(%d+)/fdinfo/%d+:iff:%s+([^%s]+)"
				local pid, iface = string.match(line, iff_pattern)
				local ff = io.open("/proc/" .. pid .. "/cmdline", "rb")
				local c = ff:read("a")
				ff:close()
				c = string.gsub(c, "\x00", " ")
				if not links[iface].cmdlines then
					links[iface].cmdlines = {}
				end
				table.insert(links[iface].cmdlines, c)
			end
			f:close()
		end  -- Grab process list

		-- TODO add checks for more vpn types, e.g., l2tp/ipsec, pptp, etc
		-- Auto-detect VPN interfaces
		if (not args.skipvpncheck) then
			local f = io.popen("sudo wg")
			for line in f:lines() do
				local iface = line:match("^interface: ([^%s]+)")
				if iface and links[iface] then
					links[iface].is_wireguard = true
					links[iface].is_vpn = true
					links[iface].is_drvpn = links[iface].default_route
				end
			end
			for iface, s in pairs(links) do
				if iface:match("^tun") and s.cmdlines then
					-- TUN/TAP devices are never in an "UP" state, but if there's a
					-- running process associated with it, it's probably connected
					if string.match(table.concat(s.cmdlines), "openvpn") then
						s.is_vpn = true
						s.is_openvpn = true
						s.is_drvpn = s.default_route
					elseif string.match(table.concat(s.cmdlines), "vpnc") then
						s.is_vpn = true
						s.is_vpnc = true
						s.is_drvpn = s.default_route
					end
				end
			end
		end

		for _, s in ipairs(links) do
			table.insert(ifaces, s)
		end
		return ifaces
	end  -- function get_interfaces()

	-- Wired indicator function ???
	local function wired_text_grabber()
		if not real_interfaces then
			return "Interface data not loaded"
		end
		local msg = ""
		for _, s in pairs(real_interfaces) do
			i = s.iface
			msg = msg .. "\n<span font_desc=\"" .. font .. "\">"
			msg = msg .. "┌[" .. s.iface .. "]"
			if s.is_vpn then
				if s.is_drvpn then
					msg = msg .. " - Full VPN"
				else
					msg = msg .. " - Partial VPN"
				end
				if s.is_openvpn then
					msg = msg .. " - (OpenVPN)"
				elseif s.is_vpnc then
					msg = msg .. " - (Cisco3000/vpnc)"
				elseif s.is_wireguard then
					msg = msg .. " - (WireGuard)"
				end
			elseif s.state then  -- not a VPN but we have state
				msg = msg .. " - state is " .. s.state
			end
			msg = msg .. "\n"

			-- Show process information
			if not args.skipcmdline then
				if  s.cmdlines then
					for _, c in pairs(s.cmdlines) do
						msg = msg .. "├CMD:\t" .. c .. "\n"
					end
				end
			end

			-- Show IP and MAC addresses
			for a = 1, #s.addrs - 1 do
				msg = msg .. "├ADDR:\t" .. s.addrs[a].addr ..
				" (" .. s.addrs[a].type_ .. ")\n"
			end
			if (args.skiproutes) then
				msg = msg .. "└ADDR:\t" .. s.addrs[#s.addrs].addr ..
				" (" .. s.addrs[#s.addrs].type_ .. ")</span>\n"
			else
				msg = msg .. "├ADDR:\t" .. s.addrs[#s.addrs].addr ..
				" (" .. s.addrs[#s.addrs].type_ .. ")\n"
			end

			-- Grab route information
			if (not args.skiproutes) then
				if s.default_route then
					msg = msg .. "├IS A DEFAULT ROUTE\n"
				end
				if s.rts then
					for _, rt in pairs(s.rts) do
						msg = msg .. "├RTE:\t" .. rt .. "\n"
					end
				end
				if (s.localrts and #s.localrts > 0) then
					for rt = 1, #s.localrts - 1 do
						msg = msg .. "├LOC:\t" .. s.localrts[rt] .. "\n"
					end
					msg = msg .. "└LOC:\t" .. s.localrts[#s.localrts] .. "</span>\n"
				else
					msg = msg .. "└LOC:\tNO LOCAL ROUTE</span>\n"
				end
			end
		end
		return msg
	end  -- function wired_text_grabber()

	-- Create the widget
	local net_icon = wibox.widget {
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			image = draw_signal(0),
			resize = false
		},
		layout = wibox.container.margin(_, 0, 0, -1)
	}
	local net_text = wibox.widget.textbox()
	net_text.font = font
	net_text:set_text(" N/A ")

	-- Function to update widget
	local signal_level = 0
	local function net_update()
		awful.spawn.easy_async("awk 'NR==3 {printf \"%3.0f\" ,($3/70)*100}' /proc/net/wireless", function(stdout, stderr, reason, exit_code)
			signal_level = tonumber( stdout )
		end)
		if signal_level == nil then
			connected = false
			net_text:set_text(" N/A ")
			net_icon.icon:set_image(draw_signal(0))
		else
			connected = true
			net_text:set_text(string.format("%"..indent.."d%%", signal_level))
			net_icon.icon:set_image(draw_signal(signal_level))
		end


		-- Refresh interface data
		real_interfaces = get_interfaces()

		-- Override wireless icon/text if ethernet on top of wifi connected
		for _, s in pairs(real_interfaces) do
			if (not args.skipvpncheck and s.is_drvpn) then
				-- widget:set_widget(vpn)
				net_icon.icon:set_image(beautiful.icon.vpn_connected)
				net_text:set_text("VPN")
				break
			elseif (s.state == "UP") then
				-- widget:set_widget(wired)
				net_icon.icon:set_image(beautiful.icon.wired_connected)
				net_text:set_text("ETH")
			end
		end -- for each real_interface
	end

	net_update()
	local timer = gears.timer.start_new( timeout, function () net_update() return true end )

	widgets_table["imagebox"]	= net_icon
	widgets_table["textbox"]	= net_text
	if widget then
		-- Create the composite widget
		widget = wibarutil.compose_widget(net_icon, net_text,
		beautiful.network_fg, beautiful.network_bg)
		-- Add notification on hover
		wireless:attach(widget,{onclick = onclick})
	end



	local function wireless_text_grabber()
		local wired_msg = wired_text_grabber()
		local msg = wired_msg
		if connected then
			local mac     = "N/A"
			local essid   = "N/A"
			local bitrate = "N/A"
			local inet    = "N/A"

			-- Use iw/ip
			f = io.popen("iw dev "..interface.." link")
			for line in f:lines() do
				-- Connected to 00:01:8e:11:45:ac (on wlp1s0)
				mac     = string.match(line, "Connected to ([0-f:]+)") or mac
				-- SSID: 00018E1145AC
				essid   = string.match(line, "SSID: (.+)") or essid
				-- tx bitrate: 36.0 MBit/s
				bitrate = string.match(line, "tx bitrate: (.+/s)") or bitrate
			end
			f:close()

			f = io.popen("ip addr show "..interface)
			for line in f:lines() do
				inet    = string.match(line, "inet (%d+%.%d+%.%d+%.%d+)") or inet
			end
			f:close()

			signal = ""
			if popup_signal then
				signal = "├Strength\t"..signal_level.."\n"
			end
			msg = msg .. "\n" ..
			"<span font_desc=\""..font.."\">"..
			"┌["..interface.."]\n"..
			"├ESSID:\t\t"..essid.."\n"..
			"├IP:\t\t"..inet.."\n"..
			"├BSSID\t\t"..mac.."\n"..
			""..signal..
			"└Bit rate:\t"..bitrate.."</span>"


		else
			msg = msg .. "\nWireless network is disconnected"
		end

		return msg
	end

	local notification = nil
	function wireless:hide()
		if notification ~= nil then
			naughty.destroy(notification)
			notification = nil
		end
	end

	function wireless:show(t_out)
		wireless:hide()

		notification = naughty.notify({
			preset = fs_notification_preset,
			text = wireless_text_grabber(),
			timeout = t_out,
			screen = mouse.screen,
			position = popup_position
		})
	end
	return widget or widgets_table
end

function wireless:attach(widget, args)
	local args = args or {}
	local onclick = args.onclick
	-- Bind onclick event function
	if onclick then
		widget:buttons(awful.util.table.join(
		awful.button({}, 1, function() awful.util.spawn(onclick) end)
		))
	end
	widget:connect_signal('mouse::enter', function () wireless:show(0) end)
	widget:connect_signal('mouse::leave', function () wireless:hide() end)
	return widget
end

setmetatable(wireless, {__call = function(_,...) return worker(...) end})

return wireless({
	-- Update these when the laptop changes interfaces
	interface = "wlp0s20f3",
	interfaces = {"enx9cebe8c05358", "enp6s0f1"},
	timeout = 5
})
