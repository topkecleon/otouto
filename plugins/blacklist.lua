 -- Admins can blacklist a user from utilizing this bot. Use via reply or with an ID as an argument. Un-blacklist a user with the same command.

local triggers = {
	'^/blacklist',
	'^/listofcolor'
}

local action = function(msg)

	if not config.admins[msg.from.id] then
		return send_msg(msg, 'Permission denied.')
	end

	local name
	local input = get_input(msg.text)
	if not input then
		if msg.reply_to_message then
			input = msg.reply_to_message.from.id
			name = msg.reply_to_message.from.first_name
		else
			return send_msg(msg, 'Must be used via reply or by specifying a user\'s ID.')
		end
	end

	local id = tostring(input)
	if not name then name = id end

	if blacklist[id] then
		blacklist[id] = nil
		send_message(msg.chat.id, name .. ' has been removed from the blacklist.')
	else
		blacklist[id] = true
		send_message(msg.chat.id, name .. ' has been blacklisted.')
	end

	save_data('blacklist.json', blacklist)

end

return {
	doc = doc,
	triggers = triggers,
	action = action
}
