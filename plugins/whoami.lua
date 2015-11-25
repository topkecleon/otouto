local triggers = {
	'^/who[ami]*[@'..bot.username..']*$'
}

local action = function(msg)

	if msg.reply_to_message then
		msg = msg.reply_to_message
	end

	local from_name = msg.from.first_name
	if msg.from.last_name then
		from_name = from_name .. ' ' .. msg.from.last_name
	end
	if msg.from.username then
		from_name = '@' .. msg.from.username .. ', AKA ' .. from_name
	end
	from_name = from_name .. ' (' .. msg.from.id .. ')'

	local to_name
	if msg.chat.title then
		to_name = msg.chat.title .. ' (' .. math.abs(msg.chat.id) .. ').'
	else
		to_name = '@' .. bot.username .. ', AKA ' .. bot.first_name .. ' (' .. bot.id .. ').'
	end

	local message = 'You are ' .. from_name .. ' and you are messaging ' .. to_name

	local nicks = load_data('nicknames.json')
	if nicks[msg.from.id_str] then
		message = message .. '\nYour nickname is ' .. nicks[msg.from.id_str] .. '.'
	end

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers
}
