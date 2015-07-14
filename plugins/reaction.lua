local PLUGIN = {}

PLUGIN.triggers = {
	['¯\\_(ツ)_/¯'] = config.COMMAND_START .. 'shrug$',
	['( ͡° ͜ʖ ͡°)'] = config.COMMAND_START .. 'lenny$',
	['(╯°□°）╯︵ ┻━┻'] = config.COMMAND_START .. 'flip$',
	['┌（┌　＾o＾）┐'] = config.COMMAND_START .. 'homo$',
	['ಠ_ಠ'] = config.COMMAND_START .. 'look$'
}

function PLUGIN.action(msg)

	local message = string.lower(msg.text)

	if msg.reply_to_message then
		msg = msg.reply_to_message
	end

	for k,v in pairs(PLUGIN.triggers) do
		if string.match(message, v) then
			return send_msg(msg, k)
		end
	end

end

return PLUGIN
