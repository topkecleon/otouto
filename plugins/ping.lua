 -- Actually the simplest plugin ever!

local triggers = {
	'^/ping[@'..bot.username..']*',
	'^/annyong[@'..bot.username..']*'
}

local action = function(msg)
	sendMessage(msg.chat.id, msg.text_lower:match('^/ping') and 'Pong!' or 'Annyong.')
end

return {
	action = action,
	triggers = triggers
}
