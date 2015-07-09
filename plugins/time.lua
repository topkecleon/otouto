 -- TIME_OFFSET is the number of seconds necessary to correct your system clock to UTC.

local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('time.COMMAND') .. ' <' .. I18N('ARG_LOCATION') .. '>\n' .. I18N('time.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('time.COMMAND')
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	coords = get_coords(input)
	if not coords then
		local message = I18N('NOT_FOUND')
		return send_msg(msg, message)
	end

	local url = 'http://maps.googleapis.com/maps/api/timezone/json?location=' .. coords.lat ..','.. coords.lon .. '&timestamp='..os.time()
	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		return send_msg(msg, I18N('CONNECTION_ERROR'))
	end
	local jdat = JSON.decode(jstr)

	local timestamp = os.time() + jdat.rawOffset + jdat.dstOffset + config.TIME_OFFSET
	timestamp = os.date("%H:%M on %A, %B %d.", timestamp)
	local timeloc = (string.gsub((string.sub(jdat.timeZoneId, string.find(jdat.timeZoneId, '/')+1)), '_', ' '))
	local message = I18N('time.RESULT', { TIMELOC = timeloc, TIMESTAMP = timestamp })

	send_msg(msg, message)

end

return PLUGIN
