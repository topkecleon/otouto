local PLUGIN = {}

PLUGIN.doc = [[
	!time <location>
	Sends the time and timezone for a given location.
]]

PLUGIN.triggers = {
	'^!time'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	coords = get_coords(input)
	if not coords then
		local message = 'Error: \"' .. input .. '\" not found.'
		return send_msg(msg, message)
	end

	local url = 'http://maps.googleapis.com/maps/api/timezone/json?location=' .. coords.lat ..','.. coords.lon .. '&timestamp='..os.time()
	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		return send_msg(msg, 'Connection error.')
	end
	local jdat = JSON.decode(jstr)

	local timestamp = os.time() + jdat.rawOffset + jdat.dstOffset + config.TIME_OFFSET
	timestamp = os.date("%H:%M on %A, %B %d.", timestamp)
	local timeloc = (string.gsub((string.sub(jdat.timeZoneId, string.find(jdat.timeZoneId, '/')+1)), '_', ' '))
	local message = "The time in " .. timeloc .. " is " .. timestamp

	send_msg(msg, message)

end

return PLUGIN
