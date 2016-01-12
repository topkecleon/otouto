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
	if output == nil then
		output = 'Done!'
	elseif type(output) == 'table' then
		output = 'Done! Table returned.'
	else
		output = '```\n' .. tostring(output) .. '\n```'
	end
	sendMessage(msg.chat.id, output, true, msg.message_id, true)

end

return {
	action = action,
	triggers = triggers
}

