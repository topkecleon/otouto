local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('gMaps.COMMAND') .. ' <' .. I18N('ARG_LOCATION') .. '>\n' .. I18N('gMaps.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('gMaps.COMMAND')
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local url = 'http://maps.googleapis.com/maps/api/geocode/json?address=' .. URL.escape(input)
	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, I18N('CONNECTION_ERROR'))
	end

	local jdat = JSON.decode(jstr)

	if jdat.status ~= 'OK' then
		local message = I18N('NOT_FOUND')
		return send_msg(msg, message)
	end

	local lat = jdat.results[1].geometry.location.lat
	local lng = jdat.results[1].geometry.location.lng
	send_location(msg.chat.id, lat, lng, msg.message_id)

end

return PLUGIN

