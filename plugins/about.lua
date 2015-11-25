local doc = [[
	/about
	Get info about the bot.
]]

local triggers = {
	''
}

local action = function(msg)

	local message = config.about_text .. '\nBased on otouto v'..version..' by topkecleon.\notouto v3 is licensed under the GPLv2.\ntopkecleon.github.io/otouto'

	if msg.new_chat_participant and msg.new_chat_participant.id == bot.id then
		sendMessage(msg.chat.id, message)
		return
	elseif string.match(msg.text_lower, '^/about[@'..bot.username..']*') then
		sendReply(msg, message)
		return
	end

	return true

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
