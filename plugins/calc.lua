local doc = [[
	/calc <expression>
	Returns solutions to mathematical expressions and conversions between common units. Results provided by mathjs.org.
]]

local triggers = {
	'^/calc[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendReply(msg, doc)
			return
		end
	end

	local url = 'https://api.mathjs.org/v1/?expr=' .. URL.escape(input)

	local ans, res = HTTPS.request(url)
	if not ans then
		sendReply(msg, config.errors.connection)
		return
	end

	sendReply(msg, ans)

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
