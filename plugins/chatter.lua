 -- Put this absolutely at the end, even after greetings.lua.

local triggers = {
	'',
	'^' .. bot.first_name .. ','
}

local action = function(msg)

	-- This is awkward, but if you have a better way, please share.
	if not (msg.text_lower:match('^' .. bot.first_name .. ',') or
	   msg.reply_to_message and msg.reply_to_message.from.id == bot.id or
	   msg.from.id == msg.chat.id) then
		return true
	end

	sendChatAction(msg.chat.id, 'typing')

	local input = msg.text_lower:gsub(bot.first_name, 'simsimi')

	local url = 'http://www.simsimi.com/requestChat?lc=en&ft=1.0&req=' .. URL.escape(input)

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		sendMessage(msg.chat.id, config.errors.chatter_connection)
		return
	end

	local jdat = JSON.decode(jstr)
	local message = jdat.res.msg

	if message:match('^I HAVE NO RESPONSE.') then
		message = config.errors.chatter_response
	end

	-- Let's clean up the response a little. Capitalization & punctuation.
	local filter = {
		['%aimi?%aimi?'] = bot.first_name,
		['^%s*(.-)%s*$'] = '%1',
		['^%l'] = string.upper,
		['USER'] = msg.from.first_name
	}

	for k,v in pairs(filter) do
		message = string.gsub(message, k, v)
	end

	if not string.match(message, '%p$') then
		message = message .. '.'
	end

	sendMessage(msg.chat.id, message)

end

return {
	action = action,
	triggers = triggers
}
