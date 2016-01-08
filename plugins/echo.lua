local command = 'echo <text>'
local doc = [[```
/echo <text>
Repeats a string of text.
```]]

local triggers = {
	'^/echo[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()

	if input then
		sendMessage(msg.chat.id, latcyr(input))
	else
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
	end

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
