local doc = [[
	/echo <text>
	Repeat a string of text!
]]

local triggers = {
	'^/echo[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()

	if input then
		sendReply(msg, latcyr(input))
	else
		sendReply(msg, doc)
	end

end

return {
	action = action,
	triggers = triggers,
	doc = doc
}
