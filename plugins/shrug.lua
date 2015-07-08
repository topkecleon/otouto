local PLUGIN = {}

PLUGIN.triggers = {
	'/shrug'
}

function PLUGIN.action(msg)

	if msg.reply_to_message then
		msg = msg.reply_to_message
	end

	send_msg(msg, '¯\\_(ツ)_/¯')

end

return PLUGIN
