 -- Put this absolutely at the end, even after greetings.lua.

local triggers = {
	''
}

local action = function(msg)

	if not msg.reply_to_message then
		return true
	elseif msg.reply_to_message and msg.reply_to_message.from.id ~= bot.id then
		return true
	end

	sendChatAction(msg.chat.id, 'typing')

	local url = 'http://www.simsimi.com/requestChat?lc=en&ft=1.0&req=' .. URL.escape(msg.text_lower)

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
