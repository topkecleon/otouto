local triggers = {
	'^/me',
	'^/me@'..bot.username
}

local action = function(msg)

	local target = database.users[msg.from.id_str]

	if msg.from.id == config.admin and (msg.reply_to_message or msg.text:input()) then
		target = user_from_message(msg)
		if target.err then
			sendReply(msg, target.err)
			return
		end
	end

	local output = ''
	for k,v in pairs(target) do
		output = output .. '*' .. k .. ':* `' .. v .. '`\n'
	end
	sendMessage(msg.chat.id, output, true, nil, true)

end

return {
	triggers = triggers,
	action = action
}
