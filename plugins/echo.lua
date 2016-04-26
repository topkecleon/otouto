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

	if not input then
		sendMessage(msg.chat.id, doc, true, msg.message_id, true)
	else
		local output
		if msg.chat.type == 'supergroup' then
			output = 'Echo:\n"' .. markdown_escape(input) .. '"'
		else
			output = latcyr(input)
		end
		sendMessage(msg.chat.id, output, true)
	end


end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
