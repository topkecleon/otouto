local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.whoami.command .. '\n' .. locale.whoami.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.whoami.command,
	'^' .. config.COMMAND_START .. 'ping',
	'^' .. config.COMMAND_START .. 'who$'
}

function PLUGIN.action(msg)

	if msg.from.id == msg.chat.id then
		to_name = '@' .. bot.username .. ' (' .. bot.id .. ')'
	else
		to_name = string.gsub(msg.chat.title, '_', ' ') .. ' (' .. string.gsub(msg.chat.id, '-', '') .. ')'
	end

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

	local message = locale.whoami.result
	message = message:gsub('#TO_NAME', to_name)
	message = message:gsub('#FROM_NAME', from_name)

	send_msg(msg, message)

end

return PLUGIN
