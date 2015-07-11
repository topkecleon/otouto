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
