 -- time_offset is the number of seconds necessary to correct your system clock to UTC.

local PLUGIN = {}

PLUGIN.doc = [[
	/time <location>
	Sends the time and timezone for a given location.
]]

PLUGIN.triggers = {
	'^/time'
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local coords = get_coords(input)
	if not coords then
		return send_msg(msg, config.locale.errors.results)
	end

	local url = 'https://maps.googleapis.com/maps/api/timezone/json?location=' .. coords.lat ..','.. coords.lon .. '&timestamp='..os.time()

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end

	local jdat = JSON.decode(jstr)

	local timestamp = os.time() + jdat.rawOffset + jdat.dstOffset + config.time_offset

	local utcoff = (jdat.rawOffset + jdat.dstOffset) / 3600
	if utcoff == math.abs(utcoff) then
		utcoff = '+' .. utcoff
	end

	local message = os.date('%I:%M %p\n', timestamp) .. os.date('%A, %B %d, %Y\n', timestamp) .. jdat.timeZoneName .. ' (UTC' .. utcoff .. ')'

	send_msg(msg, message)

end

return PLUGIN
