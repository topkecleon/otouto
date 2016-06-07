local time = {}

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

time.command = 'time <location>'

function time:init(config)
	time.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('time', true).table
	time.doc = [[```
]]..config.cmd_pat..[[time <location>
Returns the time, date, and timezone for the given location.
```]]
end

function time:action(msg, config)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, time.doc, true, msg.message_id, true)
			return
		end
	end

	local coords = utilities.get_coords(input, config)
	if type(coords) == 'string' then
		utilities.send_reply(self, msg, coords)
		return
	end

	local now = os.time()
	local utc = os.time(os.date("!*t", now))

	local url = 'https://maps.googleapis.com/maps/api/timezone/json?location=' .. coords.lat ..','.. coords.lon .. '&timestamp='..utc

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)

	local timestamp = now + jdat.rawOffset + jdat.dstOffset
	local utcoff = (jdat.rawOffset + jdat.dstOffset) / 3600
	if utcoff == math.abs(utcoff) then
		utcoff = '+'.. utilities.pretty_float(utcoff)
	else
		utcoff = utilities.pretty_float(utcoff)
	end
	local output = os.date('!%I:%M %p\n', timestamp) .. os.date('!%A, %B %d, %Y\n', timestamp) .. jdat.timeZoneName .. ' (UTC' .. utcoff .. ')'
	output = '```\n' .. output .. '\n```'

	utilities.send_reply(self, msg, output, true)

end

return time
