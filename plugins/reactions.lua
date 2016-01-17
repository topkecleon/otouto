local command = 'reactions'
local doc = '`Returns a list of "reaction" emoticon commands.`'

local triggers = {
	['¯\\_(ツ)_/¯'] = '/shrug',
	['( ͡° ͜ʖ ͡°)'] = '/lenny',
	['(╯°□°）╯︵ ┻━┻'] = '/flip',
	['┌（┌　＾o＾）┐'] = '/homo',
	['ಠ_ಠ'] = '/look',
	['SHOTS FIRED'] = '/shots?'
}

 -- Generate a "help" message triggered by "/reactions".
local help = ''
for k,v in pairs(triggers) do
	help = help .. v:gsub('?', '') .. ': ' .. k .. '\n'
	v = v .. '[@'..bot.username..']*'
end
triggers[help] = '^/reactions$'

local action = function(msg)

	for k,v in pairs(triggers) do
		if string.match(msg.text_lower, v) then
			sendMessage(msg.chat.id, k)
			return
		end
	end

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
