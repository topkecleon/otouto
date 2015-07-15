local PLUGIN = {}

PLUGIN.triggers = {
	['¯\\_(ツ)_/¯'] = '/shrug$',
	['( ͡° ͜ʖ ͡°)'] = '/lenny$',
	['(╯°□°）╯︵ ┻━┻'] = '/flip$',
	['┌（┌　＾o＾）┐'] = '/homo$',
	['ಠ_ಠ'] = '/look$'
}

function PLUGIN.action(msg)

	local message = string.lower(msg.text)

	for k,v in pairs(PLUGIN.triggers) do
		if string.match(message, v) then
			message = k
		end
	end

	if msg.reply_to_message then
		send_msg(msg.reply_to_message, message)
	else
		send_message(msg.chat.id, message)
	end

end

return PLUGIN
