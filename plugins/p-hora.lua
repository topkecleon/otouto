local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[hora <lugar>
	Envia la hora de un lugar.
]]

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. 'hora'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	coords = get_coords(input)
	if not coords then
		local message = 'No pude encontrar nada, ' .. msg.from.first_name .. '...  '
		return send_msg(msg, message)
	end

	local url = 'http://maps.googleapis.com/maps/api/timezone/json?location=' .. coords.lat ..','.. coords.lon .. '&timestamp='..os.time()
	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		return send_msg(msg, 'No pude encontar nada, ' .. msg.from.first_name .. '...  ')
	end
	local jdat = JSON.decode(jstr)

	local timestamp = os.time() + jdat.rawOffset + jdat.dstOffset + config.TIME_OFFSET
	timestamp = os.date("%H:%M de %A, %B %d.", timestamp)
	local timeloc = (string.gsub((string.sub(jdat.timeZoneId, string.find(jdat.timeZoneId, '/')+1)), '_', ' '))
	local message = "La hora en " .. timeloc .. " es " .. timestamp

	--print 'os.time()'
	--print os.time()
	--print 'timestamp'
	--print timestamp

	send_msg(msg, message)

end

return PLUGIN
