local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.help.command .. '\n' .. locale.help.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.help.command,
	'^' .. config.COMMAND_START .. 'h$',
	'^' .. config.COMMAND_START .. 'start$'
}

function PLUGIN.action(msg)

	if string.find(msg.text, '@') and not string.match(msg.text, 'help@'..bot.username) then return end

	local input = get_input(msg.text)

	if(msg.from.id == 11987707) then
		return send_msg(msg, 'Mario, ¿no te cansas de hacer el tonto?')
	end

	if input then
		for i,v in ipairs(plugins) do
			if v.doc then
				if '/' .. input == trim_string(first_word(v.doc)) then
					return send_msg(msg, v.doc)
				end
			end
		end
	end

	local message = locale.help.available_commands.. '\n' .. help_message .. locale.help.arguments

	if msg.from.id ~= msg.chat.id then
		if not send_message(msg.from.id, message, true, msg.message_id) then
			return send_msg(msg, message) -- Unable to PM user who hasn't PM'd first.
		end
		return send_msg(msg, locale.pm_info)
	else
		return send_msg(msg, message)
	end

end

return PLUGIN
