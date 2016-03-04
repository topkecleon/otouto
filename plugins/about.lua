local command = 'about'
local doc = '`Returns information about the bot.`'

local triggers = {
	''
}

local action = function(msg)

	-- Filthy hack, but here is where we'll stop forwarded messages from hitting
	-- other plugins.
	if msg.forward_from then return end

	local message = config.about_text .. '\nBased on @otouto v'..version..' by topkecleon.'

	if msg.new_chat_participant and msg.new_chat_participant.id == bot.id then
		sendMessage(msg.chat.id, message, true)
		return
	elseif msg.text_lower:match('^/about[@'..bot.username..']*') then
		sendMessage(msg.chat.id, message, true)
		return
	elseif msg.text_lower:match('^/start') then
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
