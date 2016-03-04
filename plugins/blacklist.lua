 -- This plugin will allow the admin to blacklist users who will be unable to
 -- use the bot. This plugin should be at the top of your plugin list in config.

if not database.blacklist then
	database.blacklist = {}
end

local triggers = {
	''
}

 local action = function(msg)

	if database.blacklist[msg.from.id_str] then
		return -- End if the sender is blacklisted.
	end

	if not string.match(msg.text_lower, '^/blacklist') then
		return true
	end

	if msg.from.id ~= config.admin then
		return -- End if the user isn't admin.
	end

	local target, input
	if msg.reply_to_message then
		target = msg.reply_to_message.from.id
	else
		input = msg.text:input()
		if input then
			input = get_word(input, 1)
			if tonumber(input) then
				target = input
			else
				target = resolve_username(input)
				if target == nil then
					sendReply(msg, 'Sorry, I do not recognize that username.')
					return
				elseif target == false then
					sendReply(msg, 'Invalid ID or username.')
					return
				end
			end
		else
			sendReply(msg, 'You must use this command via reply or by specifying an ID or username.')
			return
		end
	end

	target = tostring(target)

	if database.blacklist[target] then
		database.blacklist[target] = nil
		sendReply(msg, input .. ' has been removed from the blacklist.')
	else
		database.blacklist[target] = true
		sendReply(msg, input .. ' has been added to the blacklist.')
	end

 end

 return {
	action = action,
	triggers = triggers
}
