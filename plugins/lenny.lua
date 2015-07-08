local PLUGIN = {}

PLUGIN.triggers = {
	'/lenny'
}

function PLUGIN.action(msg)

	if msg.reply_to_message then
		msg = msg.reply_to_message
	end

	send_msg(msg, '( ͡° ͜ʖ ͡°)')

end

return PLUGIN
