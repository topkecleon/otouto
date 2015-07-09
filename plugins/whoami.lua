local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('whoami.COMMAND') .. '\n' .. I18N('whoami.HELP')

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. I18N('whoami.COMMAND'),
	'^' .. config.COMMAND_START .. 'ping',
}

function PLUGIN.action(msg)

	local from_name = msg.from.first_name
	if msg.from.last_name then
		from_name = from_name .. ' ' .. msg.from.last_name
	end
	if msg.from.username then
		from_name = '@' .. msg.from.username .. ', AKA ' .. from_name
	end
	from_name = from_name .. ' (' .. msg.from.id .. ')'

	if msg.from.id == msg.chat.id then
		to_name = '@' .. bot.username .. ' (' .. bot.id .. ')'
	else
		to_name = string.gsub(msg.chat.title, '_', ' ') .. ' (' .. string.gsub(msg.chat.id, '-', '') .. ')'
	end

	local message = I18N('whoami.RESPONSE', {FROM = from_name, TO = to_name})

	send_msg(msg, message)

end

return PLUGIN
