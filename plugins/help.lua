local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. I18N('help.COMMAND') .. ' [' .. I18N('ARG_COMMAND') .. ']\n' .. I18N('help.HELP')

PLUGIN.triggers = {
	'^'.. config.COMMAND_START .. I18N('help.COMMAND'),
	'^'.. config.COMMAND_START ..'h$'
}

function PLUGIN.action(msg)

	if string.find(msg.text, '@') and not string.match('help@'..bot.username) then return end

	local input = get_input(msg.text)

	if input then
		for i,v in ipairs(plugins) do
			if v.doc then
				if config.COMMAND_START .. input == trim_string(first_word(v.doc)) then
					return send_msg(msg, v.doc)
				end
			end
		end
	end

	local message = I18N('help.AVAILABLE_COMMANDS')
	message = message .. '\n' .. help_message
	message = message .. '\n' .. I18N('help.ARGUMENTS')
	message = message .. '\n' .. I18N('help.SPECIFIC_INFORMATION', {COMMAND_START = config.COMMAND_START, COMMAND = I18N('help.COMMAND'), ARG_COMMAND = I18N('ARG_COMMAND')})
 
	if msg.from.id ~= msg.chat.id then
		if not send_message(msg.from.id, message, true, msg.message_id) then
			return send_msg(msg, message) -- Unable to PM user who hasn't PM'd first.
		end
		return send_msg(msg, I18N('help.SEND_IN_PM'))
	else
		return send_msg(msg, message)
	end

end

return PLUGIN
