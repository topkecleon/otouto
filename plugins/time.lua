 -- TIME_OFFSET is the number of seconds necessary to correct your system clock to UTC.

local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.time.command .. '\n' .. locale.time.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.time.command
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	coords = get_coords(input)
	if not coords then
		return send_msg(msg, locale.noresults)
	end

	local url = 'http://maps.googleapis.com/maps/api/timezone/json?location=' .. coords.lat ..','.. coords.lon .. '&timestamp='..os.time()
	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		return send_msg(msg, locale.conn_err)
	end
	local jdat = JSON.decode(jstr)

	local timestamp = os.time() + jdat.rawOffset + jdat.dstOffset + config.TIME_OFFSET
	timestamp = os.date("%H:%M on %A, %B %d.", timestamp)
	local timeloc = (string.gsub((string.sub(jdat.timeZoneId, string.find(jdat.timeZoneId, '/')+1)), '_', ' '))
	local message = locale.time.result
	message = message:gsub('#TIMESTAMP', timestamp)
	message = message:gsub('#TIMELOC', timeloc)

	send_msg(msg, message)

end

return PLUGIN
