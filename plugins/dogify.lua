local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.dogify.command .. '\n' .. locale.dogify.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.dogify.command,
	'^' .. config.COMMAND_START .. 'doge '
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	local input = string.gsub(input, ' ', '')
	local input = string.lower(input)

	url = 'http://dogr.io/' .. input .. '.png'

	send_message(msg.chat.id, url, false, msg.message_id)

end

return PLUGIN
