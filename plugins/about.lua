local command = 'about'
local doc = '`Returns information about the bot.`'

local triggers = {
	''
}

local action = function(msg)

	-- Filthy hack, but here is where we'll stop forwarded messages from hitting
	-- other plugins.
	if msg.forward_from then return end

	local message = config.about_text .. '\nBased on otouto v'..version..' by topkecleon.\notouto v3 is licensed under the GPLv2.\ngithub.com/topkecleon/otouto'

	if msg.new_chat_participant and msg.new_chat_participant.id == bot.id then
		sendMessage(msg.chat.id, message, true)
		return
	elseif string.match(msg.text_lower, '^/about[@'..bot.username..']*') then
		sendMessage(msg.chat.id, message, true)
		return
	end

	return true

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
