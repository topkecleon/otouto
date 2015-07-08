local PLUGIN = {}

PLUGIN.doc = [[
	]] .. config.COMMAND_START .. [[help [command]
	Get list of basic information for all commands, or more detailed documentation on a specified command.
]]

PLUGIN.triggers = {
	'^'.. config.COMMAND_START ..'help',
	'^'.. config.COMMAND_START ..'h$',
	'^'.. config.COMMAND_START ..'help'
}

function PLUGIN.action(msg)

	if string.find(msg.text, '@') and not string.match('help@'..bot.username) then return end

	local input = get_input(msg.text)

	if input then
		for i,v in ipairs(plugins) do
			if v.doc then
				if '!' .. input == trim_string(first_word(v.doc)) then
					return send_msg(msg, v.doc)
				end
			end
		end
	end

	local message = '\n\nAvailable commands:\n' .. help_message .. '\n' .. [[
		*Arguments: <required> [optional]
		Use "]] .. config.COMMAND_START .. [[ help <command>" for specific information.
		otouto v]] .. VERSION .. [[ by @topkecleon forked by @luksireiku.]] .. '\n\n' .. [[
		Fork me on github!]] .. '\ngithub.com/topkecleon/otouto\ngithub.com/luksireiku/otouto'

	if msg.from.id ~= msg.chat.id then
		if not send_message(msg.from.id, message, true, msg.message_id) then
			return send_msg(msg, message) -- Unable to PM user who hasn't PM'd first.
		end
		return send_msg(msg, 'I have sent you the requested information in a private message.')
	else
		return send_msg(msg, message)
	end

end

return PLUGIN
