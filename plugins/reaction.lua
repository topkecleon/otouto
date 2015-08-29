local doc = [[
	/reactions
	Get a list of the available reaction emoticons.
]]

local triggers = {
	['¯\\_(ツ)_/¯'] = '/shrug$',
	['( ͡° ͜ʖ ͡°)'] = '/lenny$',
	['(╯°□°）╯︵ ┻━┻'] = '/flip$',
	['┌（┌　＾o＾）┐'] = '/homo$',
	['ಠ_ಠ'] = '/look$'
}

local action = function(msg)

	local message = string.lower(msg.text)

	for k,v in pairs(triggers) do
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

-- The following block of code will generate a list of reactions add the trigger "/reactions" to display it.
-- Thanks to @Imandaneshi for the idea and early implementation.
local help = ''
for k,v in pairs(triggers) do
	if v ~= '^/reactions?' then
		help = help .. v:gsub('%$', ': ') .. k .. '\n'
	end
end
triggers[help] = '^/reactions'

return {
	triggers = triggers,
	action = action,
	doc = doc
}
