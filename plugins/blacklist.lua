 -- Admins can blacklist a user from utilizing this bot. Use via reply or with an ID as an argument. Un-blacklist a user with the same command.

local triggers = {
	'^/blacklist'
}

local action = function(msg)

	if not config.admins[msg.from.id] then
		return send_msg(msg, 'Permission denied.')
	end

	local input = get_input(msg.text)
	if not input then
		if msg.reply_to_message then
			input = msg.reply_to_message.from.id
		else
			return send_msg(msg, 'Must be used via reply or by specifying a user\'s ID.')
		end
	end

	local id = tostring(input)

	if config.blacklist[id] then
		config.blacklist[id] = nil
		send_msg(msg, 'User has been removed from the blacklist.')
	else
		config.blacklist[id] = true
		send_msg(msg, 'User has been blacklisted.')
	end

	save_data('blacklist.json', config.blacklist)

end

return {
	doc = doc,
	triggers = triggers,
	action = action,
	no_typing = true
}
