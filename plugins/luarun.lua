local triggers = {
	'^/lua[@'..bot.username..']*'
}

local action = function(msg)

	if msg.from.id ~= config.admin then
		return
	end

	local input = msg.text:input()
	if not input then
		sendReply(msg, 'Please enter a string to load.')
		return
	end

	local output = loadstring(input)()
	if not output then output = 'Done!' end
	sendReply(msg, output)

end

return {
	action = action,
	triggers = triggers
}

