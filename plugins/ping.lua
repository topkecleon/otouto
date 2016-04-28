 -- Actually the simplest plugin ever!

local triggers = {
	'^/ping[@'..bot.username..']*',
	'^/annyong[@'..bot.username..']*'
}

local action = function(msg)
	local output = msg.text_lower:match('^/ping') and 'Pong!' or 'Annyong.'
	sendMessage(msg.chat.id, output)
end

return {
	action = action,
	triggers = triggers
}
