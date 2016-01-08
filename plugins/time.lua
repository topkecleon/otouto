local command = 'time <location>'
local doc = [[```
/time <location>
Returns the time, date, and timezone for the given location.
```]]

local triggers = {
	'^/time[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendMessage(msg.chat.id, doc, true, msg.message_id, true)
			return
		end
	end

	local coords = get_coords(input)
	if type(coords) == 'string' then
		sendReply(msg, coords)
		return
	end

	local url = 'https://maps.googleapis.com/maps/api/timezone/json?location=' .. coords.lat ..','.. coords.lon .. '&timestamp='..os.time()

	local jstr, res = HTTPS.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)

	local timestamp = os.time() + jdat.rawOffset + jdat.dstOffset + config.time_offset
	local utcoff = (jdat.rawOffset + jdat.dstOffset) / 3600
	if utcoff == math.abs(utcoff) then
		utcoff = '+' .. utcoff
	end
	local message = os.date('%I:%M %p\n', timestamp) .. os.date('%A, %B %d, %Y\n', timestamp) .. jdat.timeZoneName .. ' (UTC' .. utcoff .. ')'

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
